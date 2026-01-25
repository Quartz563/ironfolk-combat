defmodule IronfolkCombat.Repo.Migrations.AddAdminFieldToMisconductReport do
  use Ecto.Migration

  def change do
      alter table(:misconduct_reports) do
        add :severity, :string, default: "medium"
        add :admin_notes, {:array, :map}, default: []
      end
    end
  end
