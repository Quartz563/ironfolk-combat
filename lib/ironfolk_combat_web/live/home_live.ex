defmodule IronfolkCombatWeb.HomeLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombatWeb.Components.InfoCard
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(IronfolkCombat.PubSub, "alerts")
      Phoenix.PubSub.subscribe(IronfolkCombat.PubSub, "events")
    end

    socket =
      socket
      |> assign(:alert, Admin.get_current_alert())
      |> assign(:events, Admin.list_upcoming_events(3))

    {:ok, socket}
  end

  @impl true
  def handle_event("dismiss_alert", _params, socket) do
    {:noreply, assign(socket, :alert, nil)}
  end

  @impl true
  def handle_info({:alert_updated, _alert}, socket) do
    {:noreply, assign(socket, :alert, get_current_alert())}
  end

  @impl true
  def handle_info({:alert_deleted, _alert}, socket) do
    {:noreply, assign(socket, :alert, get_current_alert())}
  end

  @impl true
  def handle_info({:events_updated}, socket) do
    {:noreply, assign(socket, :events, Admin.list_upcoming_events(3))}
  end

  # Private functions

  defp get_current_alert do
    IronfolkCombat.Admin.get_current_alert()
  end

  defp get_upcoming_events do
    IronfolkCombat.Admin.list_active_events()
  end

  defp alert_color(:info), do: "bg-blue-600 text-white"
  defp alert_color(:warning), do: "bg-yellow-500 text-gray-900"
  defp alert_color(:error), do: "bg-red-600 text-white"
  defp alert_color(_), do: "bg-gray-600 text-white"

  defp alert_icon(%{type: :info} = assigns) do
    ~H"""
    <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      >
      </path>
    </svg>
    """
  end

  defp alert_icon(%{type: :warning} = assigns) do
    ~H"""
    <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
      >
      </path>
    </svg>
    """
  end

  defp alert_icon(%{type: :error} = assigns) do
    ~H"""
    <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      >
      </path>
    </svg>
    """
  end

  defp alert_icon(assigns) do
    ~H"""
    <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      >
      </path>
    </svg>
    """
  end
end
