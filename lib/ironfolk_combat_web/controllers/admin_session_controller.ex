defmodule IronfolkCombatWeb.AdminSessionController do
  use IronfolkCombatWeb, :controller
  alias IronfolkCombat.Admin
  alias IronfolkCombatWeb.AdminAuth

  def new(conn, _params) do
    render(conn, :new, page_title: "Admin Login")
  end

  def create(conn, %{"admin" => %{"email" => email, "password" => password}}) do
    case Admin.authenticate_admin(email, password) do
      {:ok, admin} ->
        conn
        |> AdminAuth.log_in_admin(admin)
        |> redirect(to: ~p"/admin/dashboard")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new, page_title: "Admin Login")
    end
  end

  def delete(conn, _params) do
    conn
    |> AdminAuth.log_out_admin()
    |> redirect(to: ~p"/admin/login")
  end
end
