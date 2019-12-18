use Mix.Config

# Configure your database
config :metahcr, Metahcr.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "metahcradmin",
  password: "user01",
  database: "metahcr_public_v34",
  hostname: "localhost",
  pool_size: 10
