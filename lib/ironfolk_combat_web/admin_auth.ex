defmodule IronfolkCombatWeb.AdminAuth do
  @moduledoc """
  Helper functions for admin authentication.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias IronfolkCombat.Admin

  def log_in_admin(conn, admin) do
    conn
    |> put_session(:admin_id, admin.id)
    |> put_flash(:info, "Welcome back, #{admin.name}!")
    |> configure_session(renew: true)
  end

  def log_out_admin(conn) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully.")
  end

  def get_current_admin(conn) do
    case get_session(conn, :admin_id) do
      nil -> nil
      admin_id -> Admin.get_admin_by_id(admin_id)
    end
  end
end
