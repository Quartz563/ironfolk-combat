defmodule IronfolkCombat.Repo.Migrations.CreateSignups do
  use Ecto.Migration

  def change do
    create table(:signups) do
      add(:first_name, :string, null: false)
      add(:last_name, :string, null: false)
      add(:email, :string, null: false)
      add(:phone, :string, null: false)
      add(:age_range, :string)
      add(:experience_level, :string)
      add(:emergency_contact_name, :string, null: false)
      add(:emergency_contact_phone, :string, null: false)
      add(:medical_conditions, :text)
      add(:waiver_agreement, :boolean, default: false)
      add(:contact_agreement, :boolean, default: false)
      add(:status, :string, default: "pending")

      timestamps()
    end

    create(index(:signups, [:email]))
    create(index(:signups, [:status]))
  end
end
