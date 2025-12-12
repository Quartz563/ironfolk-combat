defmodule IronfolkCombatWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug to ensure user is authenticated as an admin.
  Redirects to login page if not authenticated.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias IronfolkCombat.Admin

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :admin_id) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: "/admin/login")
        |> halt()

      admin_id ->
        # Load admin and assign to conn
        case Admin.get_admin_by_id(admin_id) do
          nil ->
            conn
            |> configure_session(drop: true)
            |> put_flash(:error, "Admin account not found.")
            |> redirect(to: "/admin/login")
            |> halt()

          admin ->
            assign(conn, :current_admin, admin)
        end
    end
  end
end
