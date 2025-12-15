defmodule IronfolkCombat.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  # Event type options
  @event_types [
    "ironfolk",
    "tournament",
    "workshop",
    "social",
    "training",
    "general"
  ]

  schema "events" do
    field(:name, :string)
    field(:event_date, :date)
    field(:location, :string)
    field(:link, :string)
    field(:description, :string)
    field(:active, :boolean, default: true)
    field(:event_type, :string, default: "general")

    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :event_date, :location, :link, :description, :active, :event_type])
    |> validate_required([:name, :event_date, :location])
    |> validate_inclusion(:event_type, @event_types)
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

  @doc """
  Formats a date for display in New Zealand format (DD/MM/YYYY)
  """
  def format_date(%Date{} = date) do
    day = String.pad_leading(Integer.to_string(date.day), 2, "0")
    month = String.pad_leading(Integer.to_string(date.month), 2, "0")
    year = Integer.to_string(date.year)
    "#{day}/#{month}/#{year}"
  end

  def format_date(_), do: ""

  @doc """
  Formats a date in a longer format for display (e.g., "15 November 2025")
  Use this for headers, titles, or where more context is helpful
  """
  def format_date_long(%Date{} = date) do
    Calendar.strftime(date, "%d %B %Y")
  end

  def format_date_long(_), do: ""
end
