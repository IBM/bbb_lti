# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bbb_lti,
  ecto_repos: [BbbLti.Repo]

config :bbb_lti,
  auth_config: [
    username: System.get_env("API_ACCESS_KEY"),
    password: System.get_env("API_SECRET_KEY")
  ]

config :bbb_lti, bbb_endpoint: System.get_env("BIGBLUEBUTTON_ENDPOINT")
config :bbb_lti, bbb_secret: System.get_env("BIGBLUEBUTTON_SECRET")

# Configures the endpoint
config :bbb_lti, BbbLtiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tmmPQ+wkIrsfp1M6Ed/oXjQUUkcLLHxLqe/Xbxmej3mLlD7El0Ax7OfU4TJJmDtB",
  render_errors: [view: BbbLtiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BbbLti.PubSub,
  live_view: [signing_salt: "BlWdfk/3"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :kaffy,
  admin_title: "Admin | BigBlueButton LTI",
  otp_app: :bbb_lti,
  ecto_repo: BbbLti.Repo,
  router: BbbLtiWeb.Router,
  extensions: [
    BbbLtiWeb.Admin.LogoutButtonExtension
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
