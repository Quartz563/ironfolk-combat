defmodule IronfolkCombatWeb.IFNLookupLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Members

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "IFN Lookup")
      |> assign(:search_type, "email")
      |> assign(:search_value, "")
      |> assign(:member, nil)
      |> assign(:searched, false)
      |> assign(:loading, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("update_search_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :search_type, type)}
  end

  @impl true
  def handle_event("update_search_value", %{"value" => value}, socket) do
    {:noreply, assign(socket, :search_value, value)}
  end

  @impl true
  def handle_event("search", _params, socket) do
    search_type = socket.assigns.search_type
    search_value = String.trim(socket.assigns.search_value)

    socket = assign(socket, :loading, true)

    case search_member(search_type, search_value) do
      nil ->
        {:noreply,
         socket
         |> assign(:member, nil)
         |> assign(:searched, true)
         |> assign(:loading, false)
         |> put_flash(:error, "No member found with that #{search_type}.")}

      member ->
        # Display the member's IFN on the page
        {:noreply,
         socket
         |> assign(:member, member)
         |> assign(:searched, true)
         |> assign(:loading, false)
         |> put_flash(:info, "Member found! Your Ironfolk ID is displayed below.")}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:search_value, "")
     |> assign(:member, nil)
     |> assign(:searched, false)
     |> clear_flash()}
  end

  defp search_member("email", email) do
    Members.get_member_by_email(email)
  end

  defp search_member("name", name) do
    Members.search_member_by_name(name)
  end
end
