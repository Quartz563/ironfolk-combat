defmodule IronfolkCombat.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:name, :string, null: false)
      add(:role, :string, default: "admin")
      timestamps()
    end

    create(unique_index(:admins, [:email]))
  end
end
