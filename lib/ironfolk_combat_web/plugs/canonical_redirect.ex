defmodule IronfolkCombatWeb.Plugs.CanonicalRedirect do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{host: "www.ironfolkcombat.co.nz"} = conn, _opts) do
    conn
    |> put_resp_header("location", "https://ironfolkcombat.co.nz#{conn.request_path}")
    |> send_resp(301, "")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
