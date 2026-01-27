defmodule IronfolkCombatWeb.Admin.BlogLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Blog.Post

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Manage Blog Posts")
      |> assign(:filter, "all")
      |> assign(:show_form, false)
      |> assign(:show_preview, true)
      |> assign(:show_help, false)
      |> assign(:preview_html, "")
      |> assign(:editing_post, nil)
      |> assign(:form, to_form(Post.changeset(%Post{}, %{})))
      |> load_posts()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"published" => published}, socket) do
    {:noreply, socket |> assign(:filter, published) |> load_posts()}
  end

  @impl true
  def handle_event("new_post", _params, socket) do
    # Pre-fill author name with current admin
    initial_attrs = %{
      "author_name" => socket.assigns.current_admin.name
    }

    changeset = Post.changeset(%Post{}, initial_attrs)

    socket =
      socket
      |> assign(:show_form, true)
      |> assign(:editing_post, nil)
      |> assign(:show_preview, true)
      |> assign(:show_help, false)
      |> assign(:preview_html, "")
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_post", %{"id" => id}, socket) do
    post = Admin.get_post!(id)

    # Generate initial preview
    preview_html = generate_preview(post.content)

    socket =
      socket
      |> assign(:show_form, true)
      |> assign(:editing_post, post)
      |> assign(:show_preview, true)
      |> assign(:show_help, false)
      |> assign(:preview_html, preview_html)
      |> assign_form_changeset(post)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_form", _params, socket) do
    socket =
      socket
      |> assign(:show_form, false)
      |> assign(:editing_post, nil)
      |> assign(:preview_html, "")

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_preview", _params, socket) do
    {:noreply, assign(socket, :show_preview, !socket.assigns.show_preview)}
  end

  @impl true
  def handle_event("toggle_help", _params, socket) do
    {:noreply, assign(socket, :show_help, !socket.assigns.show_help)}
  end

  @impl true
  def handle_event(
        "insert_markdown",
        %{"before" => before, "after" => after_text, "placeholder" => placeholder},
        socket
      ) do
    # Push the markdown insertion to the client-side hook
    {:noreply,
     push_event(socket, "insert-markdown", %{
       before: before,
       after: after_text,
       placeholder: placeholder
     })}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    # Get content for preview
    content = Map.get(post_params, "content", "")
    preview_html = generate_preview(content)

    changeset =
      (socket.assigns.editing_post || %Post{})
      |> Post.changeset(post_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> assign(:preview_html, preview_html)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"post" => post_params, "action" => action}, socket) do
    # Set published based on action button clicked
    post_params =
      case action do
        "publish" -> Map.put(post_params, "published", "true")
        "draft" -> Map.put(post_params, "published", "false")
        _ -> post_params
      end

    case socket.assigns.editing_post do
      nil -> create_post(socket, post_params)
      post -> update_post(socket, post, post_params)
    end
  end

  # Fallback for form submission without action button
  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    case socket.assigns.editing_post do
      nil -> create_post(socket, post_params)
      post -> update_post(socket, post, post_params)
    end
  end

  @impl true
  def handle_event("toggle_publish", %{"id" => id}, socket) do
    post = Admin.get_post!(id)

    case Admin.update_post(post, %{published: !post.published}) do
      {:ok, _post} ->
        message = if post.published, do: "Post unpublished", else: "Post published"

        socket =
          socket
          |> put_flash(:info, message)
          |> load_posts()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update post")}
    end
  end

  @impl true
  def handle_event("delete_post", %{"id" => id}, socket) do
    post = Admin.get_post!(id)

    case Admin.delete_post(post) do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post deleted successfully")
          |> load_posts()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete post")}
    end
  end

  # Private functions

  defp create_post(socket, post_params) do
    admin = socket.assigns.current_admin

    # Add author_id if not present (for reference)
    post_params = Map.put_new(post_params, "author_id", admin.id)

    case Admin.create_post(post_params) do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully")
          |> assign(:show_form, false)
          |> assign(:editing_post, nil)
          |> assign(:preview_html, "")
          |> load_posts()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp update_post(socket, post, post_params) do
    case Admin.update_post(post, post_params) do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post updated successfully")
          |> assign(:show_form, false)
          |> assign(:editing_post, nil)
          |> assign(:preview_html, "")
          |> load_posts()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp load_posts(socket) do
    filter = socket.assigns.filter

    posts =
      case filter do
        "all" -> Admin.list_posts()
        "true" -> Admin.list_posts(published: true)
        "false" -> Admin.list_posts(published: false)
        _ -> Admin.list_posts()
      end

    assign(socket, :posts, posts)
  end

  defp assign_form_changeset(socket, post \\ %Post{}) do
    changeset = Post.changeset(post, %{})
    assign(socket, :form, to_form(changeset))
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  # Generate HTML preview from markdown
  defp generate_preview(""), do: ""
  defp generate_preview(nil), do: ""

  defp generate_preview(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> html
      {:error, _, _} -> "<p class='text-red-600'>Error rendering markdown</p>"
    end
  end
end
