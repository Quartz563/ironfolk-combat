defmodule IronfolkCombatWeb.EventController do
  use IronfolkCombatWeb, :controller
  alias IronfolkCombat.Admin

  def index(conn, _params) do
    events = Admin.list_active_events()
    render(conn, :index, events: events, page_title: "IronEvents")
  end

  def show(conn, %{"slug" => slug}) do
    case Admin.get_event_by_slug(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(IronfolkCombatWeb.ErrorHTML)
        |> render(:"404")

      event ->
        render(conn, :show, event: event, page_title: event.title)
    end
  end
end
