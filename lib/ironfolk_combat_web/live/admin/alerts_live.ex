defmodule IronfolkCombatWeb.Admin.AlertsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Content.Alert

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Manage Alerts")
      |> assign(:show_form, false)
      |> assign(:editing_alert, nil)
      |> assign_form_changeset()
      |> load_alerts()

    {:ok, socket}
  end

  @impl true
  def handle_event("new_alert", _params, socket) do
    {:noreply,
     socket |> assign(:show_form, true) |> assign(:editing_alert, nil) |> assign_form_changeset()}
  end

  @impl true
  def handle_event("edit_alert", %{"id" => id}, socket) do
    alert = Admin.get_alert!(id)

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_alert, alert)
     |> assign_form_changeset(alert)}
  end

  @impl true
  def handle_event("cancel_form", _params, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  @impl true
  def handle_event("validate", %{"alert" => alert_params}, socket) do
    changeset =
      (socket.assigns.editing_alert || %Alert{})
      |> Alert.changeset(alert_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"alert" => alert_params}, socket) do
    case socket.assigns.editing_alert do
      nil -> create_alert(socket, alert_params)
      alert -> update_alert(socket, alert, alert_params)
    end
  end

  @impl true
  def handle_event("deactivate", %{"id" => id}, socket) do
    alert = Admin.get_alert!(id)

    case Admin.deactivate_alert(alert) do
      {:ok, _alert} ->
        {:noreply, socket |> put_flash(:info, "Alert deactivated") |> load_alerts()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to deactivate alert")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    alert = Admin.get_alert!(id)

    case Admin.delete_alert(alert) do
      {:ok, _alert} ->
        {:noreply, socket |> put_flash(:info, "Alert deleted") |> load_alerts()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete alert")}
    end
  end

  defp create_alert(socket, params) do
    case Admin.create_alert(params) do
      {:ok, _alert} ->
        {:noreply,
         socket |> put_flash(:info, "Alert created") |> assign(:show_form, false) |> load_alerts()}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
    end
  end

  defp update_alert(socket, alert, params) do
    case Admin.update_alert(alert, params) do
      {:ok, _alert} ->
        {:noreply,
         socket |> put_flash(:info, "Alert updated") |> assign(:show_form, false) |> load_alerts()}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
    end
  end

  defp load_alerts(socket) do
    assign(socket, :alerts, Admin.list_alerts())
  end

  defp assign_form_changeset(socket, alert \\ %Alert{}) do
    assign(socket, :form, Phoenix.Component.to_form(Alert.changeset(alert, %{})))
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}), do: Admin.get_admin_by_id(admin_id)
  defp get_admin_from_session(_), do: nil

  defp alert_bg("info"), do: "bg-blue-50"
  defp alert_bg("warning"), do: "bg-yellow-50"
  defp alert_bg("error"), do: "bg-red-50"
  defp alert_bg(_), do: "bg-gray-50"

  defp alert_border("info"), do: "border-blue-500"
  defp alert_border("warning"), do: "border-yellow-500"
  defp alert_border("error"), do: "border-red-500"
  defp alert_border(_), do: "border-gray-500"
end
