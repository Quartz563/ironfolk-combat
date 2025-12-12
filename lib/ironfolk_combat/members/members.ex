defmodule IronfolkCombat.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field(:ifn, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:status, :string, default: "active")
    field(:membership_type, :string, default: "standard")
    field(:membership_expires_at, :date)

    belongs_to(:signup, IronfolkCombat.Signups.Signup)
    has_many(:payments, IronfolkCombat.Payments.Payment)

    timestamps()
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [
      :ifn,
      :first_name,
      :last_name,
      :email,
      :phone,
      :status,
      :membership_type,
      :membership_expires_at,
      :signup_id
    ])
    |> validate_required([:ifn, :first_name, :last_name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_inclusion(:status, ["active", "inactive", "suspended"])
    |> validate_inclusion(:membership_type, ["standard", "hardship"])
    |> unique_constraint(:ifn)
    |> unique_constraint(:email)
  end

  def full_name(%__MODULE__{first_name: first, last_name: last}) do
    "#{first} #{last}"
  end
end
