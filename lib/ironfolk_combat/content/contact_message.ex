defmodule IronfolkCombat.Content.ContactMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contact_messages" do
    field(:name, :string)
    field(:email, :string)
    field(:subject, :string)
    field(:message, :string)
    # unread, read, archived
    field(:status, :string, default: "unread")
    field(:admin_notes, :string)

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :email, :subject, :message, :status, :admin_notes])
    |> validate_required([:name, :email, :message])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:message, min: 10)
  end
end
