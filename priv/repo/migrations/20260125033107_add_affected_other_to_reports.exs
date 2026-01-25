defmodule IronfolkCombat.Repo.Migrations.AddAffectedOtherToReports do
  use Ecto.Migration

  def change do
    alter table(:misconduct_reports) do
          add :affected_other, :text
    end
  end
end
