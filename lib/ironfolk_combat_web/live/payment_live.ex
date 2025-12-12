defmodule IronfolkCombatWeb.PaymentLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.{Members, Payments}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Make a Payment")
      |> assign(:step, :enter_ifn)
      |> assign(:ifn, "")
      |> assign(:member, nil)
      |> assign(:membership_type, "monthly")
      |> assign(:loading, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("update_ifn", %{"ifn" => ifn}, socket) do
    {:noreply, assign(socket, :ifn, String.upcase(ifn))}
  end

  @impl true
  def handle_event("lookup_member", %{"ifn" => ifn}, socket) do
    case Members.get_member_by_ifn(String.upcase(ifn)) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Member not found. Please check your Ironfolk ID Number.")
         |> assign(:member, nil)}

      member ->
        {:noreply,
         socket
         |> assign(:member, member)
         |> assign(:step, :confirm_details)
         |> clear_flash()}
    end
  end

  @impl true
  def handle_event("select_membership_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :membership_type, type)}
  end

  def handle_event("proceed_to_payment", _params, socket) do
    member = socket.assigns.member
    membership_type_string = socket.assigns.membership_type

    # DEBUG: Log what we're working with
    require Logger
    Logger.info("=== PAYMENT DEBUG ===")
    Logger.info("Member IFN: #{member.ifn}")
    Logger.info("Membership type (string): #{inspect(membership_type_string)}")
    Logger.info("Membership type (type): #{inspect(String.valid?(membership_type_string))}")

    socket = assign(socket, :loading, true)

    # Try to convert to atom
    membership_type =
      try do
        String.to_existing_atom(membership_type_string)
      rescue
        ArgumentError ->
          Logger.error("Failed to convert '#{membership_type_string}' to existing atom")
          nil
      end

    if membership_type do
      Logger.info("Membership type (atom): #{inspect(membership_type)}")

      case Payments.create_checkout_session(member.ifn, membership_type) do
        {:ok, session} ->
          Logger.info("SUCCESS: Session created - #{session.id}")
          {:noreply, redirect(socket, external: session.url)}

        {:error, reason} ->
          Logger.error("ERROR: #{inspect(reason)}")

          {:noreply,
           socket
           |> put_flash(:error, "Payment error: #{inspect(reason)}")
           |> assign(:loading, false)}
      end
    else
      Logger.error("Could not convert membership type to atom")

      {:noreply,
       socket
       |> put_flash(:error, "Invalid membership type: #{membership_type_string}")
       |> assign(:loading, false)}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    {:noreply,
     socket
     |> assign(:step, :enter_ifn)
     |> assign(:member, nil)}
  end
end
