defmodule IronfolkCombat.Repo.Migrations.CreateMembers do
  use Ecto.Migration

 def change do
    create table(:members) do
      add :ifn, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :status, :string, default: "active"
      add :membership_type, :string, default: "standard"
      add :membership_expires_at, :date
      add :signup_id, references(:signups, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:members, [:ifn])
    create unique_index(:members, [:email])
    create index(:members, [:status])
    create index(:members, [:signup_id])
  end
end
