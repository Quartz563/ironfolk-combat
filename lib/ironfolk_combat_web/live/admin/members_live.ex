defmodule IronfolkCombatWeb.Admin.MembersLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Members

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Member List")
      |> assign(:filter, "all")
      |> assign(:selected_member, nil)
      |> assign(:show_detail_modal, false)
      |> assign(:show_edit_ifn_modal, false)
      |> assign(:editing_member, nil)
      |> assign(:new_ifn, "")
      |> load_members()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, socket |> assign(:filter, status) |> load_members()}
  end

  @impl true
  def handle_event("view_member", %{"id" => id}, socket) do
    member = Members.get_member!(String.to_integer(id))

    {:noreply,
     socket
     |> assign(:selected_member, member)
     |> assign(:show_detail_modal, true)}
  end

  @impl true
  def handle_event("close_detail_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_detail_modal, false)
     |> assign(:selected_member, nil)}
  end

  @impl true
  def handle_event("edit_ifn", %{"id" => id}, socket) do
    member = Members.get_member!(String.to_integer(id))

    {:noreply,
     socket
     |> assign(:editing_member, member)
     |> assign(:new_ifn, member.ifn)
     |> assign(:show_edit_ifn_modal, true)}
  end

  @impl true
  def handle_event("close_ifn_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_edit_ifn_modal, false)
     |> assign(:editing_member, nil)
     |> assign(:new_ifn, "")}
  end

  @impl true
  def handle_event("update_ifn_input", %{"ifn" => ifn}, socket) do
    {:noreply, assign(socket, :new_ifn, String.upcase(ifn))}
  end

  @impl true
  def handle_event("save_ifn", %{"ifn" => new_ifn}, socket) do
    member = socket.assigns.editing_member
    new_ifn = String.upcase(new_ifn)

    # Validate IFN format
    if Regex.match?(~r/^IFN-\d{4}$/, new_ifn) do
      case Members.update_member(member, %{ifn: new_ifn}) do
        {:ok, _updated_member} ->
          {:noreply,
           socket
           |> put_flash(:info, "IFN updated successfully")
           |> assign(:show_edit_ifn_modal, false)
           |> assign(:editing_member, nil)
           |> load_members()}

        {:error, changeset} ->
          error_message =
            case changeset.errors[:ifn] do
              {"has already been taken", _} -> "This IFN is already in use by another member"
              _ -> "Failed to update IFN"
            end

          {:noreply, put_flash(socket, :error, error_message)}
      end
    else
      {:noreply,
       put_flash(socket, :error, "Invalid IFN format. Must be IFN-XXXX (e.g., IFN-0042)")}
    end
  end

  @impl true
  def handle_event("deactivate_member", %{"id" => id}, socket) do
    member = Members.get_member!(String.to_integer(id))

    case Members.deactivate_member(member) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member deactivated successfully")
         |> load_members()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to deactivate member")}
    end
  end

  defp load_members(socket) do
    filter = socket.assigns.filter

    members =
      case filter do
        "all" -> Members.list_members()
        "active" -> Members.list_members(status: "active")
        "inactive" -> Members.list_members(status: "inactive")
      end

    assign(socket, :members, members)
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  defp status_badge_color("active"), do: "bg-green-100 text-green-800"
  defp status_badge_color("inactive"), do: "bg-gray-100 text-gray-800"
  defp status_badge_color("suspended"), do: "bg-red-100 text-red-800"
  defp status_badge_color(_), do: "bg-gray-100 text-gray-800"
end
