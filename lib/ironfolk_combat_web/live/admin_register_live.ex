defmodule IronfolkCombatWeb.AdminRegisterLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Accounts.Admin, as: AdminUser

  @impl true
  def mount(_params, _session, socket) do
    changeset = AdminUser.changeset(%AdminUser{}, %{})

    socket =
      socket
      |> assign(:page_title, "Register an Administrator")
      |> assign(:step, :enter_code)
      |> assign(:code, "")
      |> assign(:invite, nil)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("update_code", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, String.upcase(code))}
  end

  @impl true
  def handle_event("verify_code", %{"code" => code}, socket) do
    case Admin.validate_invite_code(String.upcase(code)) do
      {:ok, invite} ->
        {:noreply,
         socket
         |> assign(:invite, invite)
         |> assign(:step, :create_account)
         |> clear_flash()}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid invite code. Please check and try again.")
         |> assign(:invite, nil)}

      {:error, :expired} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid invite code. Please check and try again.")
         |> assign(:invite, nil)}

      {:error, :already_used} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid invite code. Please check and try again.")
         |> assign(:invite, nil)}
    end
  end

  @impl true
  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset =
      %AdminUser{}
      |> AdminUser.changeset(admin_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"admin" => admin_params}, socket) do
    case Admin.create_admin(admin_params) do
      {:ok, new_admin} ->
        # Mark invite as used
        Admin.use_admin_invite(socket.assigns.invite, new_admin.id)

        {:noreply,
         socket
         |> put_flash(:info, "Admin account created successfully! You can now log in.")
         |> push_navigate(to: ~p"/admin/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    {:noreply,
     socket
     |> assign(:step, :enter_code)
     |> assign(:invite, nil)}
  end
end
