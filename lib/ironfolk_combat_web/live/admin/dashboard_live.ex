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
      |> assign(:show_invite_modal, false)
      |> assign(:new_invite, nil)
      |> assign(:show_invites_list, false)
      |> load_dashboard_stats()

    {:ok, socket}
  end

  @impl true
  def handle_event("generate_invite", _params, socket) do
    case Admin.create_admin_invite(socket.assigns.current_admin.id) do
      {:ok, invite} ->
        {:noreply,
         socket
         |> assign(:new_invite, invite)
         |> assign(:show_invite_modal, true)
         |> put_flash(:info, "Admin invite code generated successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to generate invite code")}
    end
  end

  @impl true
  def handle_event("close_invite_modal", _params, socket) do
    {:noreply, assign(socket, :show_invite_modal, false)}
  end

  @impl true
  def handle_event("show_invites", _params, socket) do
    invites = Admin.list_all_admin_invites()

    {:noreply,
     socket
     |> assign(:invites, invites)
     |> assign(:show_invites_list, true)}
  end

  @impl true
  def handle_event("close_invites_list", _params, socket) do
    {:noreply, assign(socket, :show_invites_list, false)}
  end

  @impl true
  def handle_event("delete_invite", %{"code" => code}, socket) do
    invite = Admin.get_invite_by_code(code)

    case Admin.delete_admin_invite(invite) do
      {:ok, _} ->
        invites = Admin.list_all_admin_invites()

        {:noreply,
         socket
         |> assign(:invites, invites)
         |> put_flash(:info, "Invite deleted successfully")}

      {:error, :invite_already_used} ->
        {:noreply, put_flash(socket, :error, "Cannot delete used invites")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete invite")}
    end
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
    |> assign(:pending_invites_count, count_pending_invites())
    |> assign(:pending_misconduct_reports_count, count_pending_misconduct_reports())
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

  defp count_pending_invites do
    Admin.list_all_admin_invites()
    |> Enum.filter(fn invite ->
      !invite.used && IronfolkCombat.Accounts.AdminInvite.valid?(invite)
    end)
    |> length()
  end

  defp count_pending_misconduct_reports do
    Admin.count_pending_misconduct_reports()
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil
end
