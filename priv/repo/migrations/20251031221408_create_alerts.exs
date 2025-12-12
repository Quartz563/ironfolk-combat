defmodule IronfolkCombat.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
    create table(:alerts) do
      add(:message, :text, null: false)
      add(:type, :string, default: "info")
      add(:dismissible, :boolean, default: true)
      add(:active, :boolean, default: true)
      add(:priority, :integer, default: 0)
      add(:expires_at, :naive_datetime)
      timestamps()
    end

    create(index(:alerts, [:active]))
    create(index(:alerts, [:priority]))
  end
end
