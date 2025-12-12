defmodule IronfolkCombatWeb.Admin.MembersLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Members

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Member List")
      |> assign(:filter, "all")
      |> load_members()

    {:ok, socket}
  end

  defp load_members(socket) do
    filter = socket.assigns.filter

    members =
      case filter do
        "all" -> Members.list_members()
        "active" -> Members.list_members(status: "active")
        "inactive" -> Members.list_members(status: "inactive")
      end

    assign(socket, :members, members)
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  defp status_badge_color("active"), do: "bg-green-100 text-green-800"
  defp status_badge_color("inactive"), do: "bg-gray-100 text-gray-800"
  defp status_badge_color("suspended"), do: "bg-red-100 text-red-800"
  defp status_badge_color(_), do: "bg-gray-100 text-gray-800"
end
