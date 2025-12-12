defmodule IronfolkCombat.Repo do
  use Ecto.Repo,
    otp_app: :ironfolk_combat,
    adapter: Ecto.Adapters.Postgres
end
