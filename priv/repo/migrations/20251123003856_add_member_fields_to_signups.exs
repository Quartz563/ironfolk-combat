defmodule IronfolkCombat.Repo.Migrations.AddMemberFieldsToSignups do
  use Ecto.Migration

  def change do
    alter table(:signups) do
      add :ifn, :string
      add :member_id, references(:members, on_delete: :nilify_all)
      add :policies_acknowledged_at, :utc_datetime
      add :policies_version, :string
    end

    create index(:signups, [:ifn])
    create index(:signups, [:member_id])
  end
end
