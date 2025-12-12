# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ironfolk_combat,
  generators: [timestamp_type: :utc_datetime],
  ecto_repos: [IronfolkCombat.Repo],
  stripe_webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

# Configures the endpoint
config :ironfolk_combat, IronfolkCombatWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: IronfolkCombatWeb.ErrorHTML, json: IronfolkCombatWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: IronfolkCombat.PubSub,
  live_view: [signing_salt: "byWwQuL0"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ironfolk_combat, IronfolkCombat.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ironfolk_combat: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  ironfolk_combat: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ironfolk_combat, IronfolkCombat.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ironfolk_combat_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

if File.exists?("config/dev.secret.exs") do
  import_config "dev.secret.exs"
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
