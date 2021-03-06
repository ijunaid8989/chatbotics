# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mindvalley,
  namespace: BuyIt

# Configures the endpoint
config :mindvalley, BuyItWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4cUyG3WflB/dp6+M65Xz86QoMj20SxTcOAJ2kQC+CoDztW/bVxf0DsZywGpMEsze",
  render_errors: [view: BuyItWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BuyIt.PubSub,
  live_view: [signing_salt: "r89fs84z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mindvalley,
  webhook_token: "xAH7RP3bhRwfySRgzeYcSmubgM4ONP"

config :mindvalley,
  messenger_profile_api: "https://graph.facebook.com/v7.0/me/messenger_profile",
  messages: "https://graph.facebook.com/v7.0/me/messages",
  graph: "https://graph.facebook.com",
  watson_api: "https://api.eu-de.natural-language-understanding.watson.cloud.ibm.com/instances/875fd885-e131-42ab-8d30-60527352a78d/v1/analyze?version=2019-07-12"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
