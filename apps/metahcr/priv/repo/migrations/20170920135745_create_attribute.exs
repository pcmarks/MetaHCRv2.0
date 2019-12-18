defmodule Metahcr.Repo.Migrations.CreateAttribute do
  use Ecto.Migration

  def change do
    create table(:attribute) do

      timestamps()
    end

  end
end
