defmodule IronfolkCombat.Repo.Migrations.AddImmediateThreatBoolean do
  use Ecto.Migration

  def change do
    alter table(:misconduct_reports) do
      add :immediate_threat, :boolean
    end
  end
end
