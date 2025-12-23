defmodule IronfolkCombatWeb.PageController do
  use IronfolkCombatWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def faq(conn, _params) do
    render(conn, :faq)
  end

  def resources(conn, _params) do
    render(conn, :resources)
  end

  def code_of_conduct(conn, _params) do
    render(conn, :code_of_conduct)
  end

  def sexual_harassment(conn, _params) do
    render(conn, :sexual_harassment)
  end

  def payment_cancel(conn, _params) do
    conn
    |> put_flash(:info, "Payment cancelled. No charges were made.")
    |> redirect(to: ~p"/payment")
  end
end
