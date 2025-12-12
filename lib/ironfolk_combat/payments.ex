defmodule IronfolkCombat.Payments do
  @moduledoc """
  Handles Stripe integration and payment tracking for Ironfolk Combat memberships.
  """

  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Payments.Payment
  alias IronfolkCombat.Members
  alias IronfolkCombat.Members.Member

  # Membership fees in cents (Stripe requires cents)
  @membership_fees %{
    # $60.00
    regular_monthly: 6000,
    # $170.00
    regular_quarterly: 17000,
    # $660.00
    regular_yearly: 66000,
    # $25.00
    hardship_monthly: 2500
  }

  @doc """
  Returns structured membership options for display.
  """
  def get_membership_options do
    [
      %{
        id: :regular_monthly,
        name: "Monthly",
        price: 60.00,
        amount_cents: 6000,
        duration_months: 1,
        billing_period: "per month",
        savings: nil,
        type: :regular
      },
      %{
        id: :regular_quarterly,
        name: "Quarterly",
        price: 170.00,
        amount_cents: 17000,
        duration_months: 3,
        billing_period: "per quarter",
        savings: "Save $10",
        type: :regular
      },
      %{
        id: :regular_yearly,
        name: "Yearly",
        price: 660.00,
        amount_cents: 66000,
        duration_months: 12,
        billing_period: "per year",
        savings: "Save $60 - Best Value!",
        type: :regular
      },
      %{
        id: :hardship_monthly,
        name: "Hardship Monthly",
        price: 25.00,
        amount_cents: 2500,
        duration_months: 1,
        billing_period: "per month",
        savings: nil,
        type: :hardship
      }
    ]
  end

  @doc """
  Gets the membership fee amount in cents for a given type.
  Returns {:ok, amount} or {:error, :invalid_type}
  """
  def get_membership_fee(membership_type) when is_atom(membership_type) do
    case Map.get(@membership_fees, membership_type) do
      nil -> {:error, :invalid_type}
      amount -> {:ok, amount}
    end
  end

  @doc """
  Creates a Stripe Checkout session for a member's membership payment.

  ## Parameters
    - ifn: The member's Ironfolk ID Number (e.g., "IFN-0001")
    - membership_type: Atom representing membership type (e.g., :regular_monthly)

  ## Returns
    - {:ok, session} - Stripe session with checkout URL
    - {:error, reason} - Error message
  """
  def create_checkout_session(ifn, membership_type) when is_atom(membership_type) do
    with {:ok, member} <- validate_member(ifn),
         {:ok, amount_cents} <- get_membership_fee(membership_type),
         period_start <- Date.utc_today(),
         period_end <- calculate_period_end(period_start, membership_type),
         {:ok, session} <-
           create_stripe_session(member, amount_cents, membership_type, period_start, period_end) do
      # Create pending payment record
      create_payment(%{
        member_id: member.id,
        ifn: ifn,
        stripe_checkout_session_id: session.id,
        amount: amount_cents,
        currency: "nzd",
        status: "pending",
        payment_type: membership_type_to_string(membership_type),
        period_start: period_start,
        period_end: period_end,
        metadata: %{
          membership_type: to_string(membership_type),
          session_url: session.url,
          duration_months: get_duration_months(membership_type)
        }
      })

      {:ok, session}
    else
      {:error, :member_not_found} -> {:error, "Member not found with IFN: #{ifn}"}
      {:error, :invalid_type} -> {:error, "Invalid membership type"}
      {:error, %Stripe.Error{message: message}} -> {:error, "Stripe error: #{message}"}
      error -> {:error, "Unexpected error: #{inspect(error)}"}
    end
  end

  # Validate that member exists and is active
  defp validate_member(ifn) do
    case Members.get_member_by_ifn(ifn) do
      nil -> {:error, :member_not_found}
      member -> {:ok, member}
    end
  end

  # Calculate membership period end date based on type
  defp calculate_period_end(start_date, :regular_monthly), do: Date.add(start_date, 30)
  defp calculate_period_end(start_date, :regular_quarterly), do: Date.add(start_date, 90)
  defp calculate_period_end(start_date, :regular_yearly), do: Date.add(start_date, 365)
  defp calculate_period_end(start_date, :hardship_monthly), do: Date.add(start_date, 30)

  # Get duration in months for membership extension
  defp get_duration_months(:regular_monthly), do: 1
  defp get_duration_months(:regular_quarterly), do: 3
  defp get_duration_months(:regular_yearly), do: 12
  defp get_duration_months(:hardship_monthly), do: 1

  # Create Stripe Checkout Session
  defp create_stripe_session(member, amount_cents, membership_type, period_start, period_end) do
    Stripe.Checkout.Session.create(%{
      mode: "payment",
      success_url: "#{get_base_url()}/payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{get_base_url()}/payment/cancel",
      customer_email: member.email,
      line_items: [
        %{
          price_data: %{
            currency: "nzd",
            unit_amount: amount_cents,
            product_data: %{
              name: "Ironfolk Combat Membership - #{format_membership_type(membership_type)}",
              description:
                "Membership period: #{Date.to_string(period_start)} to #{Date.to_string(period_end)}"
              # Note: metadata removed from product_data (not supported by Stripe)
            }
          },
          quantity: 1
        }
      ],
      payment_intent_data: %{
        metadata: %{
          ifn: member.ifn,
          member_id: to_string(member.id),
          member_name: Member.full_name(member),
          membership_type: to_string(membership_type),
          duration_months: to_string(get_duration_months(membership_type)),
          period_start: Date.to_string(period_start),
          period_end: Date.to_string(period_end),
          organization: "Ironfolk Combat (Registered Charity)"
        }
      },
      metadata: %{
        ifn: member.ifn,
        member_id: to_string(member.id),
        member_name: Member.full_name(member),
        membership_type: to_string(membership_type),
        duration_months: to_string(get_duration_months(membership_type)),
        period_start: Date.to_string(period_start),
        period_end: Date.to_string(period_end)
      }
    })
  end

  # Format membership type for display
  defp format_membership_type(:regular_monthly), do: "Regular Monthly"
  defp format_membership_type(:regular_quarterly), do: "Regular Quarterly"
  defp format_membership_type(:regular_yearly), do: "Regular Yearly"
  defp format_membership_type(:hardship_monthly), do: "Hardship Monthly"

  # Convert membership type atom to string for storage
  defp membership_type_to_string(:regular_monthly), do: "regular_monthly"
  defp membership_type_to_string(:regular_quarterly), do: "regular_quarterly"
  defp membership_type_to_string(:regular_yearly), do: "regular_yearly"
  defp membership_type_to_string(:hardship_monthly), do: "hardship_monthly"

  # Get base URL for redirect URLs
  defp get_base_url do
    case Application.get_env(:ironfolk_combat, IronfolkCombatWeb.Endpoint)[:url][:host] do
      nil -> "http://localhost:4000"
      "localhost" -> "http://localhost:4000"
      host -> "https://#{host}"
    end
  end

  @doc """
  Handles successful payment from Stripe webhook.
  Retrieves the session, updates payment status, and extends membership.
  """
  def handle_successful_payment(session_id) do
    with {:ok, session} <-
           Stripe.Checkout.Session.retrieve(session_id, expand: ["payment_intent"]),
         {:ok, payment} <- get_payment_by_session_id(session_id) do
      # Extract receipt URL safely
      receipt_url =
        case session.payment_intent do
          %{charges: %{data: [charge | _]}} -> Map.get(charge, :receipt_url)
          _ -> nil
        end

      # Update payment record
      {:ok, updated_payment} =
        update_payment(payment, %{
          status: "succeeded",
          stripe_payment_intent_id: session.payment_intent.id,
          receipt_url: receipt_url
        })

      # Extend member's membership
      if payment.member_id do
        member = Members.get_member!(payment.member_id)

        # FIX: Handle both string and integer
        duration_months =
          case Map.get(payment.metadata, "duration_months", 1) do
            months when is_integer(months) -> months
            months when is_binary(months) -> String.to_integer(months)
            _ -> 1
          end

        Members.extend_membership(member, duration_months)
      end

      {:ok, updated_payment}
    else
      {:error, %Stripe.Error{message: message}} ->
        {:error, "Stripe error: #{message}"}

      {:error, :payment_not_found} ->
        {:error, "Payment record not found for session #{session_id}"}

      error ->
        {:error, "Failed to process payment: #{inspect(error)}"}
    end
  end

  @doc """
  Creates a payment record.
  """
  def create_payment(attrs) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment record.
  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a payment by Stripe checkout session ID.
  """
  def get_payment_by_session_id(session_id) do
    case Repo.get_by(Payment, stripe_checkout_session_id: session_id) do
      nil -> {:error, :payment_not_found}
      payment -> {:ok, payment}
    end
  end

  @doc """
  Gets a payment by ID.
  """
  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Lists all payments with optional filtering.
  """
  def list_payments(opts \\ []) do
    status = Keyword.get(opts, :status, :all)
    member_id = Keyword.get(opts, :member_id)

    Payment
    |> filter_by_status(status)
    |> filter_by_member(member_id)
    |> order_by([p], desc: p.inserted_at)
    |> preload(:member)
    |> Repo.all()
  end

  defp filter_by_status(query, :all), do: query
  defp filter_by_status(query, status), do: where(query, [p], p.status == ^status)

  defp filter_by_member(query, nil), do: query
  defp filter_by_member(query, member_id), do: where(query, [p], p.member_id == ^member_id)

  @doc """
  Gets total revenue for reporting.
  Returns amount in cents.
  """
  def get_total_revenue(opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    query =
      Payment
      |> where([p], p.status == "succeeded")
      |> filter_by_date_range(start_date, end_date)

    Repo.aggregate(query, :sum, :amount) || 0
  end

  @doc """
  Formats revenue from cents to dollars for display.
  """
  def format_amount(amount_cents) when is_integer(amount_cents) do
    dollars = amount_cents / 100
    "$#{:erlang.float_to_binary(dollars, decimals: 2)}"
  end

  def format_amount(_), do: "$0.00"

  defp filter_by_date_range(query, nil, nil), do: query

  defp filter_by_date_range(query, start_date, nil) do
    where(query, [p], p.inserted_at >= ^start_date)
  end

  defp filter_by_date_range(query, nil, end_date) do
    where(query, [p], p.inserted_at <= ^end_date)
  end

  defp filter_by_date_range(query, start_date, end_date) do
    where(query, [p], p.inserted_at >= ^start_date and p.inserted_at <= ^end_date)
  end
end
