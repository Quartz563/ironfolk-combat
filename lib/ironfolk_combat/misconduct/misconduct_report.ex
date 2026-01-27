defmodule IronfolkCombat.Misconduct.MisconductReport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "misconduct_reports" do
    field(:report_id, :id)
    field(:violation_type, :string)
    field(:violation_text, :string)
    field(:immediate_threat, :boolean)
    field(:immediate_threat_name, :string)
    field(:date_time, :date)
    field(:time, :time)
    field(:affected, :string)
    field(:affected_other, :string)
    field(:incident_description, :string)
    field(:other_information, :string)
    field(:name, :string, default: "ANON")
    field(:email, :string, default: "NONE_GIVEN")
    field(:follow_up, :boolean, default: false)
    field(:status, :string, default: "PENDING")
    field(:severity, :string, default: "MEDIUM")
    field(:admin_notes, {:array, :map}, default: [])
    timestamps()
  end

  def changeset(misconduct_report, attrs) do
    misconduct_report
    |> cast(attrs, [
      :violation_type,
      :violation_text,
      :immediate_threat,
      :immediate_threat_name,
      :date_time,
      :time,
      :affected,
      :affected_other,
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
      :immediate_threat,
      :incident_description,
      :affected
    ])
    |> validate_immediate_threat()
    |> validate_custom_violation()
    |> validate_email_format()
    |> validate_inclusion(:immediate_threat, [true, false])
    |> validate_inclusion(:affected, ["ME", "SOMEONE_ELSE", "MULTIPLE_PEOPLE", "OTHER"])
    |> validate_inclusion(:status, ["PENDING", "UNDER_REVIEW", "RESOLVED", "DISMISSED"])
    |> validate_inclusion(:severity, ["LOW", "MEDIUM", "HIGH", "CRITICAL"])
  end

  defp validate_email_format(changeset) do
    email = get_field(changeset, :email)

    if email in [nil, "", "NONE_GIVEN"] do
      changeset
    else
      validate_format(changeset, :email, ~r/^[^\s]+@[^\s]+$/)
    end
  end

  defp validate_immediate_threat(changeset) do
    if get_field(changeset, :immediate_threat) == true do
      validate_required(changeset, :immediate_threat_name)
    else
      changeset
    end
  end

  defp validate_custom_violation(changeset) do
    if get_field(changeset, :violation_type) == "CUSTOM" do
      validate_required(changeset, :violation_text)
    else
      changeset
    end
  end
end
