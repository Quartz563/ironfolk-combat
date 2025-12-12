defmodule IronfolkCombat.Repo.Migrations.AddEventTypeToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :event_type, :string
    end
  end
end
