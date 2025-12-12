defmodule IronfolkCombatWeb.EventsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    # Start with current month
    today = Date.utc_today()

    socket =
      socket
      |> assign(:page_title, "Events Calendar")
      |> assign(:current_date, today)
      |> assign(:selected_event, nil)
      |> load_month_data(today)

    {:ok, socket}
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    new_date = Date.add(socket.assigns.current_date, -30)
    {:noreply, socket |> assign(:current_date, new_date) |> load_month_data(new_date)}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    new_date = Date.add(socket.assigns.current_date, 30)
    {:noreply, socket |> assign(:current_date, new_date) |> load_month_data(new_date)}
  end

  @impl true
  def handle_event("today", _params, socket) do
    today = Date.utc_today()
    {:noreply, socket |> assign(:current_date, today) |> load_month_data(today)}
  end

  @impl true
  def handle_event("select_event", %{"id" => id}, socket) do
    event = Enum.find(socket.assigns.events, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, :selected_event, event)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :selected_event, nil)}
  end

  defp load_month_data(socket, date) do
    # Get first and last day of the month
    first_of_month = Date.beginning_of_month(date)
    last_of_month = Date.end_of_month(date)

    # Get all active events
    all_events = Admin.list_active_events()

    # Parse event dates and attach to each event
    events_with_dates =
      Enum.map(all_events, fn event ->
        parsed_date = get_event_date(event)
        Map.put(event, :parsed_date, parsed_date)
      end)

    # Build calendar grid (including days from previous/next month to fill weeks)
    calendar_grid = build_calendar_grid(first_of_month, last_of_month)

    socket
    |> assign(:events, events_with_dates)
    |> assign(:first_of_month, first_of_month)
    |> assign(:last_of_month, last_of_month)
    |> assign(:calendar_grid, calendar_grid)
    |> assign(:month_name, Calendar.strftime(date, "%B %Y"))
  end

  # Get the date from an event - works with both :date and :event_date fields
  defp get_event_date(%{event_date: %Date{} = date}), do: date

  defp get_event_date(%{date: date_string}) when is_binary(date_string) do
    case Event.parse_date(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp get_event_date(_), do: nil

  # Format date for display - works with both string and Date types
  defp format_event_date(%{event_date: %Date{} = date}), do: Event.format_date(date)
  defp format_event_date(%{date: date_string}) when is_binary(date_string), do: date_string
  defp format_event_date(_), do: ""

  defp build_calendar_grid(first_of_month, last_of_month) do
    # Get day of week for first day (1 = Monday, 7 = Sunday)
    first_day_of_week = Date.day_of_week(first_of_month)

    # Calculate how many days from previous month to show
    days_before = first_day_of_week - 1

    # Calculate starting date (might be in previous month)
    start_date = Date.add(first_of_month, -days_before)

    # Build 6 weeks (42 days) to ensure we always show complete weeks
    for week <- 0..5 do
      for day <- 0..6 do
        date = Date.add(start_date, week * 7 + day)

        %{
          date: date,
          in_current_month: date.month == first_of_month.month,
          is_today: date == Date.utc_today()
        }
      end
    end
  end

  defp get_events_for_date(events, date) do
    Enum.filter(events, fn event ->
      event.parsed_date == date
    end)
  end

  defp event_indicator_color(event) do
    Event.event_type_color(event.event_type)
  end
end
