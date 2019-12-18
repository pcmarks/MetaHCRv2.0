defmodule Metahcr.Repo.Migrations.CreateInvestigation do
  use Ecto.Migration

  def change do
    create table(:investigation) do

      timestamps()
    end

  end
end
