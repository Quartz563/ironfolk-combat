defmodule IronfolkCombatWeb.AdminRedirectController do
  use IronfolkCombatWeb, :controller
  alias IronfolkCombatWeb.AdminAuth

  def index(conn, _params) do
    case AdminAuth.get_current_admin(conn) do
      nil ->
        # Not logged in - redirect to login
        redirect(conn, to: ~p"/admin/login")

      _admin ->
        # Already logged in - redirect to dashboard
        redirect(conn, to: ~p"/admin/dashboard")
    end
  end
end
