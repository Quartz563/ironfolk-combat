defmodule IronfolkCombat.Misconduct.MisconductReport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "misconduct_reports" do
    field(:report_id, :id)
    field(:violation_type, :string)
    field(:immediate_threat_name, :string)
    field(:date_time, :date)
    field(:affected, :string)
    field(:incident_description, :string)
    field(:other_information, :string)
    field(:name, :string, default: "Anonymous")
    field(:email, :string, default: "None Given")
    field(:follow_up, :boolean, default: false)
    field(:status, :string, default: "pending")
    field(:severity, :string, default: "medium")
    field(:admin_notes, {:array, :map}, default: [])
    timestamps()
  end

  def changeset(misconduct_report, attrs) do
    misconduct_report
    |> cast(attrs, [
      :violation_type,
      :immediate_threat_name,
      :date_time,
      :affected,
      :incident_description,
      :other_information,
      :name,
      :email,
      :follow_up,
      :status,
      :severity,
      :admin_notes
    ])
    |> validate_required([
      :violation_type,
      :immediate_threat_name,
      :incident_description,
      :affected
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_inclusion(:affected, ["me", "someone else", "multiple people", "other"])
    |> validate_inclusion(:status, ["pending", "under_review", "resolved", "dismissed"])
    |> validate_inclusion(:severity, ["low", "medium", "high"])
  end
end
