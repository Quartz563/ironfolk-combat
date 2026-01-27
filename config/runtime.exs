import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere.

if config_env() == :prod do
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

  # The secret key base is used to sign/encrypt cookies and other secrets.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "ironfolkcombat.co.nz"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :ironfolk_combat, IronfolkCombatWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: [
      "https://ironfolkcombat.co.nz",
      "https://www.ironfolkcombat.co.nz"
    ],
    # CRITICAL: WebSocket configuration
    websocket: [
      # Increase timeout for slower connections
      timeout: 60_000,
      # Allow WebSocket connections from your domains
      check_origin: [
        "https://ironfolkcombat.co.nz",
        "https://www.ironfolkcombat.co.nz"
      ],
      # Compress WebSocket messages
      compress: true
    ],
    # Force SSL for LiveView
    force_ssl: [
      rewrite_on: [:x_forwarded_proto],
      host: nil,
      hsts: true
    ]

  # Stripe configuration
  config :ironfolk_combat,
    stripe_webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

  config :stripity_stripe,
    api_key: System.get_env("STRIPE_SECRET_KEY")

  config :ironfolk_combat, Ironfolk.Mailer,
    adapter: Swoosh.Adapters.Resend,
    api_key: System.env("RESEND_API_KEY")
end
