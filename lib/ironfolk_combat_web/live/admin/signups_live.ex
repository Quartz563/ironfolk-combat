defmodule IronfolkCombatWeb.Admin.SignupsLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin

  @impl true
  def mount(_params, session, socket) do
    admin = get_admin_from_session(session)

    socket =
      socket
      |> assign(:current_admin, admin)
      |> assign(:page_title, "Manage Signups")
      |> assign(:filter, "all")
      |> load_signups()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, socket |> assign(:filter, status) |> load_signups()}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    signup = Admin.get_signup!(id)

    result =
      case status do
        "approved" ->
          # Use the new function that creates a member too
          Admin.approve_signup_and_create_member(signup)

        _ ->
          # For other statuses, just update normally
          Admin.update_signup_status(signup, status)
      end

    case result do
      {:ok, _} ->
        message =
          if status == "approved" do
            "Signup approved and member created successfully"
          else
            "Signup status updated successfully"
          end

        socket =
          socket
          |> put_flash(:info, message)
          |> load_signups()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update signup status")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    signup = Admin.get_signup!(id)

    case Admin.delete_signup(signup) do
      {:ok, _signup} ->
        socket =
          socket
          |> put_flash(:info, "Signup deleted successfully")
          |> load_signups()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete signup")}
    end
  end

  defp load_signups(socket) do
    filter = socket.assigns.filter

    signups =
      case filter do
        "all" -> Admin.list_signups()
        status -> Admin.list_signups(status: status)
      end

    assign(socket, :signups, signups)
  end

  defp get_admin_from_session(%{"admin_id" => admin_id}) do
    Admin.get_admin_by_id(admin_id)
  end

  defp get_admin_from_session(_), do: nil

  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("approved"), do: "bg-green-100 text-green-800"
  defp status_color("contacted"), do: "bg-blue-100 text-blue-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"

  defp format_age_range(nil), do: "Not specified"
  defp format_age_range("under_18"), do: "Under 18"
  defp format_age_range("18_25"), do: "18-25"
  defp format_age_range("26_35"), do: "26-35"
  defp format_age_range("36_45"), do: "36-45"
  defp format_age_range("46_55"), do: "46-55"
  defp format_age_range("over_55"), do: "Over 55"
  defp format_age_range(range), do: range

  defp format_experience(nil), do: "Not specified"
  defp format_experience("none"), do: "Complete beginner"
  defp format_experience("some_martial_arts"), do: "Some martial arts experience"
  defp format_experience("some_hema"), do: "Some HEMA experience"
  defp format_experience("experienced_hema"), do: "Experienced HEMA practitioner"
  defp format_experience(exp), do: exp
end
