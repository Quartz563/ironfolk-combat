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
    new_date = shift_month(socket.assigns.current_date, -1)
    {:noreply, socket |> assign(:current_date, new_date) |> load_month_data(new_date)}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    new_date = shift_month(socket.assigns.current_date, 1)
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

    # Build calendar grid (including days from previous/next month to fill weeks)
    calendar_grid = build_calendar_grid(first_of_month, last_of_month)

    socket
    |> assign(:events, all_events)
    |> assign(:first_of_month, first_of_month)
    |> assign(:last_of_month, last_of_month)
    |> assign(:calendar_grid, calendar_grid)
    |> assign(:month_name, Calendar.strftime(date, "%B %Y"))
  end

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

  defp shift_month(date, months_to_shift) do
    # Get first day of current month
    first_of_month = Date.beginning_of_month(date)

    # Calculate new month/year
    new_month = first_of_month.month + months_to_shift

    {year_offset, adjusted_month} =
      cond do
        new_month > 12 -> {div(new_month - 1, 12), rem(new_month - 1, 12) + 1}
        new_month < 1 -> {div(new_month - 12, 12), rem(new_month - 12, 12) + 12}
        true -> {0, new_month}
      end

    new_year = first_of_month.year + year_offset

    # Build the new date, keeping the same day if possible
    # For example, Jan 31 -> Feb 28 (or 29 in leap years)
    days_in_new_month = Date.days_in_month(Date.new!(new_year, adjusted_month, 1))
    new_day = min(date.day, days_in_new_month)

    Date.new!(new_year, adjusted_month, new_day)
  end

  defp get_events_for_date(events, date) do
    Enum.filter(events, fn event ->
      event.event_date == date
    end)
  end

  defp event_indicator_color(event) do
    Event.event_type_color(event.event_type)
  end
end
