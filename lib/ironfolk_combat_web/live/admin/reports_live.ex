defmodule IronfolkCombatWeb.Admin.ReportsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Misconduct

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Report List")
      |> assign(:misconduct_reports, Misconduct.list_reports())

    {:ok, socket}
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  defp status_badge_color("resolved"), do: "bg-green-100 text-green-800"
  defp status_badge_color("followup"), do: "bg-gray-100 text-gray-800"
  defp status_badge_color("pending"), do: "bg-red-100 text-red-800"
  defp status_badge_color(_), do: "bg-gray-100 text-gray-800"
end
