defmodule IronfolkCombat.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  # Event type options
  @event_types [
    # Ironfolk Combat club events
    "ironfolk",
    # Competitive tournaments
    "tournament",
    # Educational workshops
    "workshop",
    # Social gatherings
    "social",
    # Special training sessions
    "training",
    # General NZ HEMA events
    "general"
  ]

  schema "events" do
    field(:name, :string)
    field(:date, :string)
    field(:location, :string)
    field(:link, :string)
    field(:description, :string)
    field(:active, :boolean, default: true)
    field(:event_type, :string, default: "general")

    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :location, :link, :description, :active, :event_type])
    |> validate_required([:name, :date, :location])
    |> validate_inclusion(:event_type, @event_types)
    |> validate_date_format()
  end

  @doc """
  Returns list of valid event types for dropdowns
  """
  def event_types, do: @event_types

  @doc """
  Returns a human-readable label for an event type
  """
  def event_type_label("ironfolk"), do: "Ironfolk Event"
  def event_type_label("tournament"), do: "Tournament"
  def event_type_label("workshop"), do: "Workshop"
  def event_type_label("social"), do: "Social Event"
  def event_type_label("training"), do: "Training Session"
  def event_type_label("general"), do: "NZ HEMA Event"
  def event_type_label(_), do: "Event"

  @doc """
  Returns the Tailwind CSS color class for an event type
  """
  def event_type_color("ironfolk"), do: "bg-pink-500"
  def event_type_color("tournament"), do: "bg-red-500"
  def event_type_color("workshop"), do: "bg-blue-500"
  def event_type_color("social"), do: "bg-green-500"
  def event_type_color("training"), do: "bg-purple-500"
  def event_type_color("general"), do: "bg-indigo-500"
  def event_type_color(_), do: "bg-gray-500"

  # Validate that the date can be parsed
  defp validate_date_format(changeset) do
    case get_change(changeset, :date) do
      nil ->
        changeset

      date_string ->
        case parse_date(date_string) do
          {:ok, _date} ->
            changeset

          {:error, _reason} ->
            add_error(
              changeset,
              :date,
              "must be in format 'DD Month YYYY' (e.g., '15 November 2025'), 'YYYY-MM-DD', or 'DD/MM/YYYY'"
            )
        end
    end
  end

  @doc """
  Parse a date string into a Date struct.
  Supports multiple formats:
  - "15 November 2025"
  - "2025-11-15"
  - "15/11/2025"
  """
  def parse_date(date_string) when is_binary(date_string) do
    cond do
      # Format: "15 November 2025"
      Regex.match?(~r/^\d{1,2}\s+\w+\s+\d{4}$/, date_string) ->
        parse_day_month_year(date_string)

      # Format: "2025-11-15"
      Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, date_string) ->
        Date.from_iso8601(date_string)

      # Format: "15/11/2025"
      Regex.match?(~r/^\d{1,2}\/\d{1,2}\/\d{4}$/, date_string) ->
        parse_slash_format(date_string)

      true ->
        {:error, :invalid_format}
    end
  end

  def parse_date(_), do: {:error, :invalid_input}

  defp parse_day_month_year(date_string) do
    parts = String.split(date_string, " ")

    if length(parts) == 3 do
      [day_str, month_name, year_str] = parts

      month_map = %{
        "january" => 1,
        "february" => 2,
        "march" => 3,
        "april" => 4,
        "may" => 5,
        "june" => 6,
        "july" => 7,
        "august" => 8,
        "september" => 9,
        "october" => 10,
        "november" => 11,
        "december" => 12
      }

      with {day, ""} <- Integer.parse(day_str),
           month when not is_nil(month) <- Map.get(month_map, String.downcase(month_name)),
           {year, ""} <- Integer.parse(year_str),
           {:ok, date} <- Date.new(year, month, day) do
        {:ok, date}
      else
        _ -> {:error, :invalid_format}
      end
    else
      {:error, :invalid_format}
    end
  end

  defp parse_slash_format(date_string) do
    case String.split(date_string, "/") do
      [day_str, month_str, year_str] ->
        with {day, ""} <- Integer.parse(day_str),
             {month, ""} <- Integer.parse(month_str),
             {year, ""} <- Integer.parse(year_str),
             {:ok, date} <- Date.new(year, month, day) do
          {:ok, date}
        else
          _ -> {:error, :invalid_format}
        end

      _ ->
        {:error, :invalid_format}
    end
  end
end
