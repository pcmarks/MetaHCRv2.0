use Mix.Config

# Configure your database
config :metahcr, Metahcr.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "metahcr_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
