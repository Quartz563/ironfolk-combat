defmodule IronfolkCombatWeb.Admin.ReportsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    # Subscribe to real-time updates
    if connected?(socket) do
      Phoenix.PubSub.subscribe(IronfolkCombat.PubSub, "misconduct_reports")
    end

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Misconduct Reports")
      |> assign(:filter, "all")
      |> assign(:selected_report, nil)
      |> assign(:show_details, false)
      |> assign(:admin_note, "")
      |> load_reports()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, socket |> assign(:filter, status) |> load_reports()}
  end

  @impl true
  def handle_event("view_report", %{"id" => id}, socket) do
    # Changed
    report = Admin.get_misconduct_report!(id)

    {:noreply,
     socket
     |> assign(:selected_report, report)
     |> assign(:show_details, true)
     |> assign(:admin_note, "")}
  end

  @impl true
  def handle_event("close_details", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_report, nil)
     |> assign(:show_details, false)}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    # Changed
    report = Admin.get_misconduct_report!(id)

    # Changed
    case Admin.update_misconduct_report_status(report, status) do
      {:ok, _report} ->
        socket =
          socket
          |> put_flash(:info, "Report status updated successfully")
          |> assign(:show_details, false)
          |> load_reports()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update report status")}
    end
  end

  @impl true
  def handle_event("validate_note", %{"note" => note}, socket) do
    {:noreply, assign(socket, :admin_note, note)}
  end

  @impl true
  def handle_event("add_note", %{"note" => note}, socket) do
    report = socket.assigns.selected_report
    admin = socket.assigns.current_admin

    if String.trim(note) == "" do
      {:noreply, put_flash(socket, :error, "Note cannot be empty")}
    else
      # Changed
      case Admin.add_misconduct_report_note(report, admin.id, note) do
        {:ok, updated_report} ->
          socket =
            socket
            |> assign(:selected_report, updated_report)
            |> assign(:admin_note, "")
            |> put_flash(:info, "Note added successfully")

          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to add note")}
      end
    end
  end

  # Handle real-time updates
  @impl true
  def handle_info({:reports_updated}, socket) do
    {:noreply, load_reports(socket)}
  end

  defp load_reports(socket) do
    filter = socket.assigns.filter

    reports =
      case filter do
        # Changed
        "all" -> Admin.list_misconduct_reports()
        # Changed
        status -> Admin.list_misconduct_reports(status: status)
      end

    assign(socket, :reports, reports)
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  # Status badge helpers remain the same
  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("under_review"), do: "bg-blue-100 text-blue-800"
  defp status_color("resolved"), do: "bg-green-100 text-green-800"
  defp status_color("dismissed"), do: "bg-gray-100 text-gray-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"

  defp severity_color("low"), do: "bg-green-100 text-green-800"
  defp severity_color("medium"), do: "bg-yellow-100 text-yellow-800"
  defp severity_color("high"), do: "bg-red-100 text-red-800"
  defp severity_color(_), do: "bg-gray-100 text-gray-800"
end
