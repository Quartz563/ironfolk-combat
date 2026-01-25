defmodule IronfolkCombatWeb.Admin.ReportsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.{Admin, Misconduct}

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(IronfolkCombat.PubSub, "misconduct_reports")
    end

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Misconduct Reports")
      |> assign(:filter_status, :all)
      |> assign(:filter_severity, :all)
      |> assign(:selected_report, nil)
      |> assign(:new_note, "")
      |> load_reports()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    filter_status = if status == "all", do: :all, else: status

    {:noreply,
     socket
     |> assign(:filter_status, filter_status)
     |> load_reports()}
  end

  @impl true
  def handle_event("filter_severity", %{"severity" => severity}, socket) do
    filter_severity = if severity == "all", do: :all, else: severity

    {:noreply,
     socket
     |> assign(:filter_severity, filter_severity)
     |> load_reports()}
  end

  @impl true
  def handle_event("select_report", %{"id" => id}, socket) do
    report = Misconduct.get_report!(id)
    {:noreply, assign(socket, selected_report: report, new_note: "")}
  end

  @impl true
  def handle_event("close_detail", _params, socket) do
    {:noreply, assign(socket, selected_report: nil, new_note: "")}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    report = Misconduct.get_report!(id)

    case Misconduct.update_report_status(report, status) do
      {:ok, updated_report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status updated successfully")
         |> assign(:selected_report, updated_report)
         |> load_reports()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  @impl true
  def handle_event("update_severity", %{"id" => id, "severity" => severity}, socket) do
    report = Misconduct.get_report!(id)

    case Misconduct.update_report_severity(report, severity) do
      {:ok, updated_report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Severity updated successfully")
         |> assign(:selected_report, updated_report)
         |> load_reports()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update severity")}
    end
  end

  @impl true
  def handle_event("update_note", %{"note" => note}, socket) do
    {:noreply, assign(socket, :new_note, note)}
  end

  @impl true
  def handle_event("add_note", %{"note" => note}, socket) do
    report = socket.assigns.selected_report
    admin = socket.assigns.current_admin

    if String.trim(note) == "" do
      {:noreply, put_flash(socket, :error, "Note cannot be empty")}
    else
      case Misconduct.add_admin_note(report, note, admin.name) do
        {:ok, updated_report} ->
          {:noreply,
           socket
           |> put_flash(:info, "Note added successfully")
           |> assign(:selected_report, updated_report)
           |> assign(:new_note, "")
           |> load_reports()}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to add note")}
      end
    end
  end

  @impl true
  def handle_event("delete_report", %{"id" => id}, socket) do
    report = Misconduct.get_report!(id)

    case Misconduct.delete_report(report) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report deleted successfully")
         |> assign(:selected_report, nil)
         |> load_reports()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete report")}
    end
  end

  @impl true
  def handle_info({:report_created, _report}, socket) do
    {:noreply, load_reports(socket)}
  end

  @impl true
  def handle_info({:report_updated, report}, socket) do
    socket =
      socket
      |> load_reports()
      |> then(fn sock ->
        if sock.assigns.selected_report && sock.assigns.selected_report.id == report.id do
          assign(sock, :selected_report, report)
        else
          sock
        end
      end)

    {:noreply, socket}
  end

  defp load_reports(socket) do
    filters =
      []
      |> maybe_add_filter(:status, socket.assigns.filter_status)
      |> maybe_add_filter(:severity, socket.assigns.filter_severity)

    reports = Misconduct.list_reports(filters)
    assign(socket, :reports, reports)
  end

  defp maybe_add_filter(filters, _key, :all), do: filters
  defp maybe_add_filter(filters, key, value), do: [{key, value} | filters]

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  # Helper functions for display
  defp status_badge_color("PENDING"), do: "bg-yellow-100 text-yellow-800"
  defp status_badge_color("IN_PROGRESS"), do: "bg-blue-100 text-blue-800"
  defp status_badge_color("RESOLVED"), do: "bg-green-100 text-green-800"
  defp status_badge_color("DISMISSED"), do: "bg-gray-100 text-gray-800"
  defp status_badge_color(_), do: "bg-gray-100 text-gray-800"

  defp severity_badge_color("LOW"), do: "bg-blue-100 text-blue-800"
  defp severity_badge_color("MEDIUM"), do: "bg-yellow-100 text-yellow-800"
  defp severity_badge_color("HIGH"), do: "bg-orange-100 text-orange-800"
  defp severity_badge_color("CRITICAL"), do: "bg-red-100 text-red-800"
  defp severity_badge_color(_), do: "bg-gray-100 text-gray-800"

  defp format_violation_type(type) do
    type
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_datetime(%Date{} = date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  defp format_datetime(nil), do: "N/A"

  defp format_time(%Time{} = time) do
    Calendar.strftime(time, "%I:%M %p")
  end

  defp format_time(nil), do: "N/A"

  defp has_immediate_threat?(report) do
    report.immediate_threat_name && String.trim(report.immediate_threat_name) != ""
  end
end
