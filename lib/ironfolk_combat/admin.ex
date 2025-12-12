defmodule IronfolkCombat.Admin do
  @moduledoc """
  The Admin context - handles all admin-related operations.
  This is the main API for interacting with admin features.
  """
  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Accounts.Admin, as: AdminUser
  alias IronfolkCombat.Signups.Signup
  alias IronfolkCombat.Blog.Post
  alias IronfolkCombat.Content.Alert
  alias IronfolkCombat.Events.Event
  alias IronfolkCombat.Members
  alias IronfolkCombat.Content.ContactMessage

  @pubsub IronfolkCombat.PubSub

  # ============================================
  # ADMIN USER FUNCTIONS
  # ============================================

  @doc """
  Gets an admin by their ID.
  Returns nil if not found.
  """
  def get_admin_by_id(id) do
    Repo.get(AdminUser, id)
  end

  @doc """
  Gets an admin by their email address.
  Returns nil if not found.
  """
  def get_admin_by_email(email) do
    Repo.get_by(AdminUser, email: email)
  end

  @doc """
  Authenticates an admin with email and password.
  Returns {:ok, admin} if successful, {:error, :invalid_credentials} otherwise.
  """
  def authenticate_admin(email, password) do
    case get_admin_by_email(email) do
      nil ->
        {:error, :invalid_credentials}

      admin ->
        if AdminUser.verify_password(admin, password) do
          {:ok, admin}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Creates a new admin user.
  """
  def create_admin(attrs \\ %{}) do
    %AdminUser{}
    |> AdminUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all admin users.
  """
  def list_admins do
    Repo.all(AdminUser)
  end

  # ============================================
  # SIGNUP MANAGEMENT
  # ============================================

  @doc """
  Lists signups with optional filtering.
  Options:
    - status: :all (default), "pending", "approved", "contacted"
  """
  def list_signups(opts \\ []) do
    status = Keyword.get(opts, :status, :all)

    Signup
    |> filter_by_status(status)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  defp filter_by_status(query, :all), do: query
  defp filter_by_status(query, status), do: where(query, [s], s.status == ^status)

  @doc """
  Gets a single signup by ID. Raises if not found.
  """
  def get_signup!(id), do: Repo.get!(Signup, id)

  @doc """
  Creates a new signup from the website form.
  """
  def create_signup(attrs \\ %{}) do
    %Signup{}
    |> Signup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a signup's status.
  Status can be: "pending", "approved", "contacted"
  """
  def update_signup_status(signup, status) do
    signup
    |> Ecto.Changeset.change(status: status)
    |> Repo.update()
  end

  @doc """
  Deletes a signup.
  """
  def delete_signup(%Signup{} = signup) do
    Repo.delete(signup)
  end

  def approve_signup_and_create_member(signup) do
    ifn = Members.generate_ifn()

    Ecto.Multi.new()
    |> Ecto.Multi.run(:member, fn repo, _changes ->
      # Create member from signup
      attrs = %{
        ifn: ifn,
        first_name: signup.first_name,
        last_name: signup.last_name,
        email: signup.email,
        phone: signup.phone,
        status: "active",
        signup_id: signup.id
      }

      %Members.Member{}
      |> Members.Member.changeset(attrs)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:signup, fn repo, _changes ->
      # Just update signup status to approved
      signup
      |> Signup.changeset(%{status: "approved", contact_agreement: true, waiver_agreement: true})
      |> repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{member: member, signup: signup}} ->
        IO.inspect(member, label: "✅ Created member")
        IO.inspect(signup, label: "✅ Updated signup")
        {:ok, member}

      {:error, failed_operation, changeset, _changes} ->
        IO.inspect(failed_operation, label: "❌ Failed at")
        IO.inspect(changeset.errors, label: "❌ Errors")
        {:error, changeset}
    end
  end

  # ============================================
  # BLOG POST MANAGEMENT
  # ============================================

  @doc """
  Lists blog posts with optional filtering.
  Options:
    - published: :all (default), true, false
  """
  def list_posts(opts \\ []) do
    published = Keyword.get(opts, :published, :all)

    Post
    |> filter_by_published(published)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Lists only published posts (for public display).
  """
  def list_published_posts do
    Post
    |> where([p], p.published == true)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  defp filter_by_published(query, :all), do: query
  defp filter_by_published(query, published), do: where(query, [p], p.published == ^published)

  @doc """
  Gets a single post by ID. Raises if not found.
  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Gets a published post by its slug (for public display).
  Returns nil if not found or not published.
  """
  def get_post_by_slug(slug) do
    Repo.get_by(Post, slug: slug, published: true)
  end

  @doc """
  Creates a new blog post.
  """
  def create_post(attrs \\ %{}) do
    case %Post{}
         |> Post.changeset(attrs)
         |> Repo.insert() do
      {:ok, post} = result ->
        if post.published do
          broadcast_blog_change(post)
        end

        result

      error ->
        error
    end
  end

  @doc """
  Updates a blog post.
  """
  def update_post(%Post{} = post, attrs) do
    case post
         |> Post.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_post} = result ->
        # Broadcast if post is now published or was already published
        if updated_post.published do
          broadcast_blog_change(updated_post)
        end

        result

      error ->
        error
    end
  end

  @doc """
  Deletes a blog post.
  """
  def delete_post(%Post{} = post) do
    case Repo.delete(post) do
      {:ok, deleted_post} = result ->
        if deleted_post.published do
          broadcast_blog_change(deleted_post)
        end

        result

      error ->
        error
    end
  end

  defp broadcast_blog_change(post) do
    Phoenix.PubSub.broadcast(@pubsub, "posts", {:post_updated, post})
  end

  # ============================================
  # ALERT MANAGEMENT
  # ============================================

  @doc """
  Lists all alerts (for admin management).
  """
  def list_alerts do
    Alert
    |> order_by([a], desc: a.priority, desc: a.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets the current alert to display on the homepage.
  Returns the highest priority active alert that hasn't expired.
  """
  def get_current_alert do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Alert
    |> where([a], a.active == true)
    |> where([a], is_nil(a.expires_at) or a.expires_at > ^now)
    |> order_by([a], desc: a.priority)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single alert by ID. Raises if not found.
  """
  def get_alert!(id), do: Repo.get!(Alert, id)

  @doc """
  Creates a new alert.
  """
  def create_alert(attrs \\ %{}) do
    case %Alert{}
         |> Alert.changeset(attrs)
         |> Repo.insert() do
      {:ok, alert} = result ->
        broadcast_alert_change(alert)
        result

      error ->
        error
    end
  end

  @doc """
  Updates an alert.
  """
  def update_alert(%Alert{} = alert, attrs) do
    case alert
         |> Alert.changeset(attrs)
         |> Repo.update() do
      {:ok, alert} = result ->
        broadcast_alert_change(alert)
        result

      error ->
        error
    end
  end

  @doc """
  Deletes an alert.
  """
  def delete_alert(%Alert{} = alert) do
    case Repo.delete(alert) do
      {:ok, alert} = result ->
        Phoenix.PubSub.broadcast(@pubsub, "alerts", {:alert_deleted, alert})
        result

      error ->
        error
    end
  end

  @doc """
  Deactivates an alert (sets active to false).
  """
  def deactivate_alert(%Alert{} = alert) do
    update_alert(alert, %{active: false})
  end

  defp broadcast_alert_change(alert) do
    Phoenix.PubSub.broadcast(@pubsub, "alerts", {:alert_updated, alert})
  end

  # ============================================
  # EVENT MANAGEMENT
  # ============================================

  @doc """
  Lists all events (for admin management).
  """
  def list_events do
    Event
    |> order_by([e], asc: e.date)
    |> Repo.all()
  end

  @doc """
  Lists only active events (for public display).
  """
  def list_active_events do
    Event
    |> where([e], e.active == true)
    |> order_by([e], asc: e.date)
    |> Repo.all()
  end

  def get_event_by_slug(slug) do
    Repo.get_by(Event, slug: slug, published: true)
  end

  @doc """
  Gets a single event by ID. Raises if not found.
  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a new event.
  """
  def create_event(attrs \\ %{}) do
    case %Event{}
         |> Event.changeset(attrs)
         |> Repo.insert() do
      {:ok, _event} = result ->
        broadcast_event_change()
        result

      error ->
        error
    end
  end

  @doc """
  Updates an event.
  """
  def update_event(%Event{} = event, attrs) do
    case event
         |> Event.changeset(attrs)
         |> Repo.update() do
      {:ok, ^event} = result ->
        broadcast_event_change()
        result

      error ->
        error
    end
  end

  @doc """
  Deletes an event.
  """
  def delete_event(%Event{} = event) do
    case Repo.delete(event) do
      {:ok, ^event} = result ->
        broadcast_event_change()
        result

      error ->
        error
    end
  end

  @doc """
  Toggles an event's active status.
  """
  def toggle_event_active(%Event{} = event) do
    update_event(event, %{active: !event.active})
  end

  @doc """
  Lists only upcoming active events (for homepage preview).
  Limited to 3 events, sorted by date.
  """
  def list_upcoming_events(limit \\ 3) do
    today = Date.utc_today()

    Event
    |> where([e], e.active == true)
    |> order_by([e], asc: e.date)
    |> Repo.all()
    |> Enum.map(fn event ->
      parsed_date = parse_event_date(event)
      Map.put(event, :parsed_date, parsed_date)
    end)
    |> Enum.filter(fn event ->
      case event.parsed_date do
        %Date{} = date -> Date.compare(date, today) in [:gt, :eq]
        _ -> false
      end
    end)
    |> Enum.take(limit)
  end

  # Helper to parse event dates
  defp parse_event_date(%{date: date_string}) when is_binary(date_string) do
    case IronfolkCombat.Events.Event.parse_date(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp parse_event_date(_), do: nil

  defp broadcast_event_change do
    Phoenix.PubSub.broadcast(@pubsub, "events", {:events_updated})
  end

  # ============================================
  # CONTACT MESSAGE MANAGEMENT
  # ============================================

  def list_contact_messages(opts \\ []) do
    status = Keyword.get(opts, :status, :all)

    ContactMessage
    |> filter_by_message_status(status)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  defp filter_by_message_status(query, :all), do: query
  defp filter_by_message_status(query, status), do: where(query, [m], m.status == ^status)

  def get_contact_message!(id), do: Repo.get!(ContactMessage, id)

  def create_contact_message(attrs \\ %{}) do
    %ContactMessage{}
    |> ContactMessage.changeset(attrs)
    |> Repo.insert()
  end

  def update_contact_message(%ContactMessage{} = message, attrs) do
    message
    |> ContactMessage.changeset(attrs)
    |> Repo.update()
  end

  def mark_message_read(%ContactMessage{} = message) do
    update_contact_message(message, %{status: "read"})
  end

  def archive_message(%ContactMessage{} = message) do
    update_contact_message(message, %{status: "archived"})
  end

  def delete_contact_message(%ContactMessage{} = message) do
    Repo.delete(message)
  end
end
