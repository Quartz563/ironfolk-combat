defmodule IronfolkCombat.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field(:ifn, :string)
    field(:stripe_payment_intent_id, :string)
    field(:stripe_checkout_session_id, :string)
    field(:amount, :integer)
    field(:currency, :string, default: "nzd")
    field(:status, :string)
    field(:payment_type, :string)
    field(:period_start, :date)
    field(:period_end, :date)
    field(:receipt_url, :string)
    field(:metadata, :map)

    belongs_to(:member, IronfolkCombat.Members.Member)
    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :member_id,
      :ifn,
      :stripe_payment_intent_id,
      :stripe_checkout_session_id,
      :amount,
      :currency,
      :status,
      :payment_type,
      :period_start,
      :period_end,
      :receipt_url,
      :metadata
    ])
    |> validate_required([:amount, :status])
    |> validate_inclusion(:status, ["pending", "succeeded", "failed", "refunded"])
    |> validate_number(:amount, greater_than: 0)
  end

  def format_amount(%__MODULE__{amount: amount, currency: currency}) do
    dollars = amount / 100
    currency_symbol = if currency == "nzd", do: "$", else: currency
    "#{currency_symbol}#{:erlang.float_to_binary(dollars, decimals: 2)}"
  end
end
