import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere.

# Don't use config_env() in releases - check if we're in a release instead
if System.get_env("RELEASE_NAME") do
  # We're in a release (production)

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :ironfolk_combat, IronfolkCombat.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "ironfolkcombat.co.nz"
  port = String.to_integer(System.get_env("PORT") || "8080")

  config :ironfolk_combat, IronfolkCombatWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true

  # Configure Stripe
  config :stripity_stripe,
    api_key: System.get_env("STRIPE_SECRET_KEY")

  config :ironfolk_combat,
    stripe_webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

  # Mailer configuration
  config :ironfolk_combat, IronfolkCombat.Mailer, adapter: Swoosh.Adapters.Local

  # Configure logger level
  config :logger, level: :info
end
