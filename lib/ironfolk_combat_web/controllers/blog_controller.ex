defmodule IronfolkCombatWeb.BlogController do
  use IronfolkCombatWeb, :controller
  alias IronfolkCombat.Admin

  def index(conn, _params) do
    posts = Admin.list_published_posts()
    render(conn, :index, posts: posts, page_title: "IronBlog")
  end

  def show(conn, %{"slug" => slug}) do
    case Admin.get_post_by_slug(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(IronfolkCombatWeb.ErrorHTML)
        |> render(:"404")

      post ->
        render(conn, :show, post: post, page_title: post.title)
    end
  end
end
