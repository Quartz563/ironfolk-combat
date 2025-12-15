defmodule IronfolkCombat.Repo.Migrations.CreateAdminInvites do
  use Ecto.Migration

  def change do
    create table(:admin_invites) do
      add :code, :string, null: false
      add :created_by_admin_id, references(:admins, on_delete: :nilify_all)
      add :used, :boolean, default: false, null: false
      add :used_by_admin_id, references(:admins, on_delete: :nilify_all)
      add :used_at, :naive_datetime
      add :expires_at, :naive_datetime, null: false
      timestamps()
    end
    create unique_index(:admin_invites, [:code])
    create index(:admin_invites, [:created_by_admin_id])
    create index(:admin_invites, [:used])
  end
end
