# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :loom, LoomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "frahOGz5li86fvNLm8q3eD6pmD54NQYPyqWcWeEHerJhx6d6g5V15a7gB+WyA13W",
  render_errors: [view: LoomWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Loom.PubSub,
  live_view: [signing_salt: "JFxC4q/rs6NIdMuoU+UXYL0A0p6RG5TN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :astra,
  id: System.get_env("ASTRA_ID"),
  region: System.get_env("ASTRA_REGION"),
  username: System.get_env("ASTRA_USERNAME"),
  password: System.get_env("ASTRA_PASSWORD")
  
# config guardian for access control
config :loom, Loom.Guardian,
  issuer: "loom",
  secret_key: "pLlmfXjzIFR03xdl14anxVcy0rOxp3HiiYUVCtmj38eUavJt8PfaawBlDFPG9l7j"

config :loom, :strategies,
  google: [
    client_id: System.get_env("GOOGLE_CLIENT_ID"),
    client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
    redirect_uri: "/auth/google/callback",
    authorization_params: [
      access_type: "offline",
      scope: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"
    ],
    strategy: Assent.Strategy.Google
  ]



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
