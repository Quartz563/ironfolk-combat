defmodule IronfolkCombatWeb.Admin.EventsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Events.Event

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Manage Events")
      |> assign(:show_form, false)
      |> assign(:editing_event, nil)
      |> assign_form_changeset()
      |> load_events()

    {:ok, socket}
  end

  @impl true
  def handle_event("new_event", _params, socket) do
    {:noreply,
     socket |> assign(:show_form, true) |> assign(:editing_event, nil) |> assign_form_changeset()}
  end

  @impl true
  def handle_event("edit_event", %{"id" => id}, socket) do
    event = Admin.get_event!(id)

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_event, event)
     |> assign_form_changeset(event)}
  end

  @impl true
  def handle_event("cancel_form", _params, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      (socket.assigns.editing_event || %Event{})
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"event" => event_params}, socket) do
    case socket.assigns.editing_event do
      nil -> create_event(socket, event_params)
      event -> update_event(socket, event, event_params)
    end
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    event = Admin.get_event!(id)

    case Admin.toggle_event_active(event) do
      {:ok, _event} ->
        {:noreply, socket |> put_flash(:info, "Event updated") |> load_events()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update event")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Admin.get_event!(id)

    case Admin.delete_event(event) do
      {:ok, _event} ->
        {:noreply, socket |> put_flash(:info, "Event deleted") |> load_events()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete event")}
    end
  end

  defp create_event(socket, params) do
    case Admin.create_event(params) do
      {:ok, _event} ->
        {:noreply,
         socket |> put_flash(:info, "Event created") |> assign(:show_form, false) |> load_events()}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
    end
  end

  defp update_event(socket, event, params) do
    case Admin.update_event(event, params) do
      {:ok, _event} ->
        {:noreply,
         socket |> put_flash(:info, "Event updated") |> assign(:show_form, false) |> load_events()}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
    end
  end

  defp load_events(socket) do
    assign(socket, :events, Admin.list_events())
  end

  defp assign_form_changeset(socket, event \\ %Event{}) do
    assign(socket, :form, Phoenix.Component.to_form(Event.changeset(event, %{})))
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}), do: Admin.get_admin_by_id(admin_id)
  defp get_admin_from_session(_), do: nil

  # Helper to get event type badge color for display
  defp event_type_badge(event_type) do
    case event_type do
      "ironfolk" -> "bg-pink-100 text-pink-800"
      "tournament" -> "bg-red-100 text-red-800"
      "workshop" -> "bg-blue-100 text-blue-800"
      "social" -> "bg-green-100 text-green-800"
      "training" -> "bg-purple-100 text-purple-800"
      "general" -> "bg-indigo-100 text-indigo-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
