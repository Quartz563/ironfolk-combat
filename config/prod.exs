import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

config :ironfolk_combat, IronfolkCombatWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  # Important: Server must be true for production
  server: true

# Do not print debug messages in production
config :logger, level: :info

# Runtime configuration (secrets, etc.) should go in config/runtime.exs
