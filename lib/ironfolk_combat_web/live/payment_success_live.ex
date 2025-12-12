defmodule IronfolkCombatWeb.PaymentSuccessLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.{Payments, Repo}
  require Logger

  @impl true
  def mount(params, _session, socket) do
    # Handle both cases in ONE mount function
    case Map.get(params, "session_id") do
      nil ->
        # No session_id provided
        socket =
          socket
          |> assign(:page_title, "Payment Status")
          |> assign(:payment, nil)
          |> assign(:member, nil)
          |> assign(:error, "Invalid payment session")

        {:ok, socket}

      session_id ->
        # Session_id provided
        case Payments.get_payment_by_session_id(session_id) do
          {:ok, payment} ->
            payment = Repo.preload(payment, :member)

            socket =
              socket
              |> assign(:page_title, "Payment Successful")
              |> assign(:payment, payment)
              |> assign(:member, payment.member)
              |> assign(:session_id, session_id)
              |> assign(:error, nil)

            {:ok, socket}

          {:error, _reason} ->
            Logger.error("Payment not found for session: #{session_id}")

            socket =
              socket
              |> assign(:page_title, "Payment Status")
              |> assign(:payment, nil)
              |> assign(:member, nil)
              |> assign(:session_id, session_id)
              |> assign(:error, "Payment not found")

            {:ok, socket}
        end
    end
  end

  # Helper functions
  defp format_date(%Date{} = date), do: Calendar.strftime(date, "%B %d, %Y")
  defp format_date(nil), do: "N/A"

  defp format_payment_type("regular_monthly"), do: "Regular Monthly Membership"
  defp format_payment_type("regular_quarterly"), do: "Regular Quarterly Membership"
  defp format_payment_type("regular_yearly"), do: "Regular Yearly Membership"
  defp format_payment_type("hardship_monthly"), do: "Hardship Monthly Membership"
  defp format_payment_type(type), do: String.capitalize(type)
end
