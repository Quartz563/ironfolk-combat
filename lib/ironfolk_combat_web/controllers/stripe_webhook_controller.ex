defmodule IronfolkCombatWeb.StripeWebhookController do
  use IronfolkCombatWeb, :controller
  alias IronfolkCombat.Payments

  def webhook(conn, params) do
    # Verify webhook signature
    with {:ok, event} <- verify_webhook(conn, params) do
      handle_event(event)
      send_resp(conn, 200, "OK")
    else
      {:error, _reason} ->
        send_resp(conn, 400, "Bad Request")
    end
  end

  defp verify_webhook(conn, _params) do
    signature = get_req_header(conn, "stripe-signature") |> List.first()
    webhook_secret = Application.get_env(:ironfolk_combat, :stripe_webhook_secret)

    Stripe.Webhook.construct_event(
      conn.assigns.raw_body,
      signature,
      webhook_secret
    )
  end

  defp handle_event(%{type: "checkout.session.completed", data: %{object: session}}) do
    Payments.handle_successful_payment(session.id)
  end

  defp handle_event(_event), do: :ok
end
