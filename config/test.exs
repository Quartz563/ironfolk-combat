import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ironfolk_combat, IronfolkCombatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YIiaVMf08/1vMvxJZCAyKLPre3FGpsqy02lREs1JoVHdDrrwZUyMoKNmYHXWiAw3",
  server: false

# In test we don't send emails
config :ironfolk_combat, IronfolkCombat.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :ironfolk_combat, IronfolkCombat.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ironfolk_combat_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
