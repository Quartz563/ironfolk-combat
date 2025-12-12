defmodule IronfolkCombat.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:name, :string, null: false)
      add(:date, :string, null: false)
      add(:location, :string, null: false)
      add(:link, :string)
      add(:description, :text)
      add(:active, :boolean, default: true)
      timestamps()
    end

    create(index(:events, [:active]))
  end
end
