# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

config :bbb_lti,
  auth_config: [
    username: System.get_env("API_ACCESS_KEY"),
    password: System.get_env("API_SECRET_KEY")
  ]

config :bbb_lti, bbb_endpoint: System.get_env("BIGBLUEBUTTON_ENDPOINT")
config :bbb_lti, bbb_secret: System.get_env("BIGBLUEBUTTON_SECRET")

config :bbb_lti, host: "https://" <> System.get_env("HOST")

config :bbb_lti, BbbLti.Repo,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOSTNAME"),
  database: System.get_env("DB_NAME"),
  ssl: if(System.get_env("DB_SSL") == "true", do: true, else: false),
  port: System.get_env("DB_PORT", "5432"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :bbb_lti, BbbLtiWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: System.get_env("HOST"), port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :bbb_lti, BbbLtiWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
