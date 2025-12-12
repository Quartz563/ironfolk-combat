defmodule IronfolkCombat.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :member_id, references(:members, on_delete: :nilify_all)
      add :ifn, :string
      add :stripe_payment_intent_id, :string
      add :stripe_checkout_session_id, :string
      add :amount, :integer, null: false
      add :currency, :string, default: "nzd"
      add :status, :string, null: false
      add :payment_type, :string
      add :period_start, :date
      add :period_end, :date
      add :receipt_url, :string
      add :metadata, :map

      timestamps()
    end

    create index(:payments, [:member_id])
    create index(:payments, [:ifn])
    create index(:payments, [:stripe_payment_intent_id])
    create index(:payments, [:stripe_checkout_session_id])
    create index(:payments, [:status])
    create index(:payments, [:inserted_at])
  end
end
