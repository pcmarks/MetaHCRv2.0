defmodule Metahcr.Application do
  @moduledoc """
  The Metahcr Application Service.

  The metahcr system business domain lives in this application.

  Exposes API to clients such as the `MetahcrWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Metahcr.Repo, []),
    ], strategy: :one_for_one, name: Metahcr.Supervisor)
  end
end
