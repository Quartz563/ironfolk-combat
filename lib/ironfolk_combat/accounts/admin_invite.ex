defmodule IronfolkCombat.Accounts.AdminInvite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admin_invites" do
    field(:code, :string)
    field(:used, :boolean, default: false)
    field(:used_at, :naive_datetime)
    field(:expires_at, :naive_datetime)

    belongs_to(:created_by, IronfolkCombat.Accounts.Admin, foreign_key: :created_by_admin_id)
    belongs_to(:used_by, IronfolkCombat.Accounts.Admin, foreign_key: :used_by_admin_id)

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:code, :created_by_admin_id, :used, :used_by_admin_id, :used_at, :expires_at])
    |> validate_required([:code, :expires_at])
    |> unique_constraint(:code)
  end

  @doc """
  Generates a new admin code
  """

  def generate_code do
    part1 = :crypto.strong_rand_bytes(2) |> Base.encode(16)
    part2 = :crypto.strong_rand_bytes(2) |> Base.encode(16)
    String.upcase("ADMIN-#{part1}-#{part2}")
  end

  @doc """
  Checks if an invite is valid (not used, not expired)
  """
  def valid?(%__MODULE__{used: true}), do: false

  def valid?(%__MODULE__{expires_at: expires_at}) do
    NativeDateTime.compare(NativeDateTime.utc_now(), expires_at) == :lt
  end
end
