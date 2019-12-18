defmodule Metahcr.Authorization do

  import Ecto.Query, warn: false
  alias Metahcr.Repo

  alias Metahcr.AuthUser

  def get_user(username) do
    query = from u in AuthUser,
      where: u.username == ^username
    Repo.one(query)
  end

end
