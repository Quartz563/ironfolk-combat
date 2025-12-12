defmodule IronfolkCombat.Content.Alert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alerts" do
    field(:message, :string)
    # info, warning, error
    field(:type, :string, default: "info")
    field(:dismissible, :boolean, default: true)
    field(:active, :boolean, default: true)
    field(:priority, :integer, default: 0)
    field(:expires_at, :naive_datetime)

    timestamps()
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:message, :type, :dismissible, :active, :priority, :expires_at])
    |> validate_required([:message, :type])
    |> validate_inclusion(:type, ["info", "warning", "error"])
  end
end
