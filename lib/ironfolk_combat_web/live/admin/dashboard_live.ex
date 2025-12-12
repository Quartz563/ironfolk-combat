defmodule IronfolkCombatWeb.Admin.DashboardLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, session, socket) do
    # Get admin from session
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Admin Dashboard")
      |> load_dashboard_stats()

    {:ok, socket}
  end

  defp load_dashboard_stats(socket) do
    socket
    |> assign(:pending_signups_count, count_pending_signups())
    |> assign(:total_signups_count, count_total_signups())
    |> assign(:total_posts_count, count_total_posts())
    |> assign(:published_posts_count, count_published_posts())
    |> assign(:draft_posts_count, count_draft_posts())
    |> assign(:active_events_count, count_active_events())
    |> assign(:active_alerts_count, count_active_alerts())
    |> assign(:unread_messages_count, count_unread_messages())
  end

  defp count_pending_signups do
    Admin.list_signups(status: "pending") |> length()
  end

  defp count_total_signups do
    Admin.list_signups() |> length()
  end

  defp count_total_posts do
    Admin.list_posts() |> length()
  end

  defp count_published_posts do
    Admin.list_posts(published: true) |> length()
  end

  defp count_draft_posts do
    Admin.list_posts(published: false) |> length()
  end

  defp count_active_events do
    Admin.list_active_events() |> length()
  end

  defp count_active_alerts do
    case Admin.get_current_alert() do
      nil -> 0
      _ -> 1
    end
  end

  defp count_unread_messages do
    Admin.list_contact_messages(status: "unread") |> length()
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil
end
