defmodule Metahcr.AuthUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias Metahcr.AuthUser

  schema "auth_user" do
    field :password, :string
    field :username, :string
  end

  def changeset(%AuthUser{} = auth_user, attrs) do
    auth_user
    |> cast(attrs, [])
    |> validate_required([])
  end

end
