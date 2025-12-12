defmodule IronfolkCombatWeb.ContactLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      IronfolkCombat.Content.ContactMessage.changeset(
        %IronfolkCombat.Content.ContactMessage{},
        %{}
      )

    socket =
      socket
      |> assign(:page_title, "Contact Us")
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"contact_message" => params}, socket) do
    changeset =
      %IronfolkCombat.Content.ContactMessage{}
      |> IronfolkCombat.Content.ContactMessage.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("send_message", %{"contact_message" => params}, socket) do
    case Admin.create_contact_message(params) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Message sent! We'll get back to you soon.")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
