import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :changelogr, Changelogr.Repo, database: "changelogr-test.db"
#  username: "postgres",
#  password: "postgres",
#  hostname: "localhost",
#  database: "changelogr_test#{System.get_env("MIX_TEST_PARTITION")}",
#  pool: Ecto.Adapters.SQL.Sandbox,
#  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :changelogr, ChangelogrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vl0l7zX2lh+why5EoTZLhix6JFHn0PpORf/BQwj0tL1EiX84c0DAqTLdod668aVP",
  server: false

# In test we don't send emails.
config :changelogr, Changelogr.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
