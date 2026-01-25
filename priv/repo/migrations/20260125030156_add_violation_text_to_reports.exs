defmodule IronfolkCombat.Repo.Migrations.AddViolationTextToReports do
  use Ecto.Migration

  def change do
    alter table(:misconduct_reports) do
          add :violation_text, :text
    end
  end
end
