defmodule IronfolkCombat.Repo.Migrations.CreateContactMessage do
  use Ecto.Migration

  def change do
      create table(:contact_messages) do
        add :name, :string, null: false
        add :email, :string, null: false
        add :subject, :string
        add :message, :text, null: false
        add :status, :string, default: "unread", null: false
        add :admin_notes, :text

        timestamps()
      end

      create index(:contact_messages, [:status])
      create index(:contact_messages, [:inserted_at])
    end
end
