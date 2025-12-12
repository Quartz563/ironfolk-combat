defmodule IronfolkCombatWeb.Admin.MessagesLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Contact Messages")
      |> assign(:filter, "all")
      |> assign(:selected_message, nil)
      |> load_messages()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, socket |> assign(:filter, status) |> load_messages()}
  end

  @impl true
  def handle_event("view_message", %{"id" => id}, socket) do
    message = Admin.get_contact_message!(id)

    # Mark as read when viewed
    if message.status == "unread" do
      Admin.mark_message_read(message)
    end

    {:noreply, socket |> assign(:selected_message, message) |> load_messages()}
  end

  @impl true
  def handle_event("close_message", _params, socket) do
    {:noreply, assign(socket, :selected_message, nil)}
  end

  @impl true
  def handle_event("mark_read", %{"id" => id}, socket) do
    message = Admin.get_contact_message!(id)
    Admin.mark_message_read(message)

    {:noreply, socket |> put_flash(:info, "Message marked as read") |> load_messages()}
  end

  @impl true
  def handle_event("archive", %{"id" => id}, socket) do
    message = Admin.get_contact_message!(id)
    Admin.archive_message(message)

    {:noreply,
     socket
     |> put_flash(:info, "Message archived")
     |> assign(:selected_message, nil)
     |> load_messages()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Admin.get_contact_message!(id)
    Admin.delete_contact_message(message)

    {:noreply,
     socket
     |> put_flash(:info, "Message deleted")
     |> assign(:selected_message, nil)
     |> load_messages()}
  end

  defp load_messages(socket) do
    filter = socket.assigns.filter

    messages =
      case filter do
        "all" -> Admin.list_contact_messages()
        status -> Admin.list_contact_messages(status: status)
      end

    assign(socket, :messages, messages)
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}), do: Admin.get_admin_by_id(admin_id)
  defp get_admin_from_session(_), do: nil

  defp status_badge("unread"), do: "bg-yellow-100 text-yellow-800"
  defp status_badge("read"), do: "bg-blue-100 text-blue-800"
  defp status_badge("archived"), do: "bg-gray-100 text-gray-800"
  defp status_badge(_), do: "bg-gray-100 text-gray-800"
end
