defmodule IronfolkCombatWeb.SignupLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Admin
  alias IronfolkCombat.Signups.Signup

  @impl true
  def mount(_params, _session, socket) do
    changeset = Signup.changeset(%Signup{}, %{})

    socket =
      socket
      |> assign(:page_title, "Join Ironfolk Combat")
      |> assign(:form, to_form(changeset))
      |> assign(:show_code_of_conduct, false)
      |> assign(:show_relationship_policy, false)
      |> assign(:code_of_conduct_read, false)
      |> assign(:relationship_policy_read, false)
      |> assign(:code_of_conduct_scrolled, false)
      |> assign(:relationship_policy_scrolled, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"signup" => signup_params}, socket) do
    changeset =
      %Signup{}
      |> Signup.changeset(signup_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"signup" => signup_params}, socket) do
    unless socket.assigns.code_of_conduct_read and socket.assigns.relationship_policy_read do
      {:noreply,
       put_flash(
         socket,
         :error,
         "Please read both the Code of Conduct and Relationship Policy before submitting."
       )}
    else
      case Admin.create_signup(signup_params) do
        {:ok, _signup} ->
          {:noreply,
           socket
           |> put_flash(:info, "Thank you for signing up! We'll be in touch soon.")
           |> push_navigate(to: ~p"/")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    end
  end

  @impl true
  def handle_event("show_code_of_conduct", _params, socket) do
    {:noreply, assign(socket, :show_code_of_conduct, true)}
  end

  @impl true
  def handle_event("show_relationship_policy", _params, socket) do
    {:noreply, assign(socket, :show_relationship_policy, true)}
  end

  @impl true
  def handle_event("close_code_of_conduct", _params, socket) do
    {:noreply, assign(socket, :show_code_of_conduct, false)}
  end

  @impl true
  def handle_event("close_relationship_policy", _params, socket) do
    {:noreply, assign(socket, :show_relationship_policy, false)}
  end

  @impl true
  def handle_event("code_of_conduct_scrolled", _params, socket) do
    {:noreply, assign(socket, :code_of_conduct_scrolled, true)}
  end

  @impl true
  def handle_event("relationship_policy_scrolled", _params, socket) do
    {:noreply, assign(socket, :relationship_policy_scrolled, true)}
  end

  @impl true
  def handle_event("mark_code_of_conduct_read", _params, socket) do
    if socket.assigns.code_of_conduct_scrolled do
      {:noreply,
       socket
       |> assign(:code_of_conduct_read, true)
       |> assign(:show_code_of_conduct, false)}
    else
      {:noreply, put_flash(socket, :error, "Please scroll to the bottom of the document")}
    end
  end

  @impl true
  def handle_event("mark_relationship_policy_read", _params, socket) do
    if socket.assigns.relationship_policy_scrolled do
      {:noreply,
       socket
       |> assign(:relationship_policy_read, true)
       |> assign(:show_relationship_policy, false)}
    else
      {:noreply, put_flash(socket, :error, "Please scroll to the bottom of the document.")}
    end
  end
end
