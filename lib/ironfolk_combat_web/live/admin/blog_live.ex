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
      |> assign(:editing_post, nil)
      |> assign(:form, to_form(Post.changeset(%Post{}, %{}), []))
      |> load_posts()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"published" => published}, socket) do
    {:noreply, socket |> assign(:filter, published) |> load_posts()}
  end

  @impl true
  def handle_event("new_post", _params, socket) do
    socket =
      socket
      |> assign(:show_form, true)
      |> assign(:editing_post, nil)
      |> assign_form_changeset()

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_post", %{"id" => id}, socket) do
    post = Admin.get_post!(id)

    socket =
      socket
      |> assign(:show_form, true)
      |> assign(:editing_post, post)
      |> assign_form_changeset(post)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_form", _params, socket) do
    socket =
      socket
      |> assign(:show_form, false)
      |> assign(:editing_post, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      (socket.assigns.editing_post || %Post{})
      |> Post.changeset(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset, []))}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    admin = socket.assigns.current_admin
    post_params = Map.put(post_params, "author_id", admin.id)
    post_params = Map.put(post_params, "author_name", admin.name)

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
        socket =
          socket
          |> put_flash(
            :info,
            "Post #{if post.published, do: "unpublished", else: "published"} successfully"
          )
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

  defp create_post(socket, post_params) do
    case Admin.create_post(post_params) do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully")
          |> assign(:show_form, false)
          |> assign(:editing_post, nil)
          |> load_posts()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset, []))}
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
          |> load_posts()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset, []))}
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
    assign(socket, :form, Phoenix.Component.to_form(changeset, []))
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil
end
