use Mix.Config

config :metahcr, ecto_repos: [Metahcr.Repo]

import_config "#{Mix.env}.exs"
