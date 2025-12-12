defmodule IronfolkCombat.Signups.Signup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "signups" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:age_range, :string)
    field(:experience_level, :string)
    field(:emergency_contact_name, :string)
    field(:emergency_contact_phone, :string)
    field(:medical_conditions, :string)
    field(:waiver_agreement, :boolean, default: false)
    field(:contact_agreement, :boolean, default: false)
    # pending, approved, contacted (assuming we want this, ofc)
    field(:status, :string, default: "pending")

    timestamps()
  end

  def changeset(signup, attrs) do
    signup
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :phone,
      :age_range,
      :experience_level,
      :emergency_contact_name,
      :emergency_contact_phone,
      :medical_conditions,
      :waiver_agreement,
      :contact_agreement,
      :status
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :email,
      :phone,
      :age_range,
      :emergency_contact_name,
      :emergency_contact_phone
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_acceptance(:waiver_agreement)
    |> validate_acceptance(:contact_agreement)
  end
end
