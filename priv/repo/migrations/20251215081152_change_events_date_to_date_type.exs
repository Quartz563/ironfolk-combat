defmodule IronfolkCombat.Repo.Migrations.ChangeEventsDateToDateType do
  use Ecto.Migration

  def up do
    alter table(:events) do
      add :event_date, :date
    end

    execute """
        UPDATE events
        SET event_date = CASE
          WHEN date ~ '^\\d{4}-\\d{2}-\\d{2}$' THEN date::date
          ELSE NULL
        END
        """

    alter table(:events) do
      remove :date
    end
  end

  def down do
      alter table(:events) do
        add :date, :string
      end

      execute "UPDATE events SET date = event_date::text"

      alter table(:events) do
        remove :event_date
      end
    end
end
