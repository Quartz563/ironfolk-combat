defmodule IronfolkCombat.Accounts.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:name, :string)
    field(:role, :string, default: "admin")

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :name, :role, :password, :password_confirmation])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:password, min: 8, message: "must be at least 8 characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Pbkdf2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  @doc """
  Verifies the password against the stored hash.
  """
  def verify_password(admin, password) do
    Pbkdf2.verify_pass(password, admin.password_hash)
  end
end
