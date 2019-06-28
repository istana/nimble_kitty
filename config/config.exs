# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nimble_kitty,
  ecto_repos: [NimbleKitty.Repo]

# Configures the endpoint
config :nimble_kitty, NimbleKittyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HOoTYTVSN+g7C/0bfQ2maBmOxN91R+Q2R1jLLicpszvSAhnV7jerIbclMHhDvppm",
  render_errors: [view: NimbleKittyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NimbleKitty.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
