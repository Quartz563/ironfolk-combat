defmodule IronfolkCombat.Repo.Migrations.AddTimeToMisconductTable do
  use Ecto.Migration

  def change do
    alter table(:misconduct_reports) do
      add :time, :utc_datetime, null: true
      modify :severity, :string, default: "MEDIUM"
    end
  end
end
