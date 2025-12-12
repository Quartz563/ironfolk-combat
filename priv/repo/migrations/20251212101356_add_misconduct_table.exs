defmodule IronfolkCombat.Repo.Migrations.AddMisconductTable do
  use Ecto.Migration

  def change do
    create table(:misconduct_reports) do
      add :report_id, :id
      add :violation_type, :string
      add :immediate_threat_name, :string
      add :date_time, :date
      add :affected, :string
      add :incident_description, :text
      add :other_information, :text
      add :name, :string
      add :email, :string
      add :follow_up, :boolean
      add :status, :string
      timestamps()
    end

    create unique_index(:misconduct_reports, [:report_id])
  end
end
