use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bbb_lti, BbbLti.Repo,
  username: "postgres",
  password: "postgres",
  database: "bbb_lti_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bbb_lti, host: "http://" <> System.get_env("HOST", "localhost:4002")

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bbb_lti, BbbLtiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
