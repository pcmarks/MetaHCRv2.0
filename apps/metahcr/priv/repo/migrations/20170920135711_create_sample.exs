defmodule Metahcr.Repo.Migrations.CreateSample do
  use Ecto.Migration

  def change do
    create table(:sample) do

      timestamps()
    end

  end
end
