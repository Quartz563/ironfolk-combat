defmodule IronfolkCombatWeb.BlogIndexLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(IronfolkCombat.PubSub, "posts")
    end

    socket =
      socket
      |> assign(:page_title, "IronBlog")
      |> load_posts()

    {:ok, socket}
  end

  @impl true
  def handle_info({:post_updated, _post}, socket) do
    {:noreply, load_posts(socket)}
  end

  defp load_posts(socket) do
    posts = Admin.list_published_posts()
    assign(socket, :posts, posts)
  end
end
