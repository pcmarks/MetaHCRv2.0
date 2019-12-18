defmodule Metahcr.Organism do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{Organism, Repo}

  schema "organism" do
    field :superkingdom, :string
    field :phylum, :string
    field :subphylum, :string
    field :bio_class, :string
    field :bio_order, :string
    field :family, :string
    field :genus, :string
    field :species, :string
  end

  @doc false
  def changeset(%Organism{} = organism, attrs) do
    organism
    |> cast(attrs, [])
    |> validate_required([])
  end

  def count_organisms do
    query = from organism in Organism, select: count(organism.id)
    List.first(Repo.all(query))
  end


  def list_organisms do
    Repo.all(Organism)
  end

  def list_organisms(page, item_count) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page

    query = from organism in Organism
    paged_query = query
            # |> preload(^@investigation_preload)
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from o in query, select: {count(o.id)}

    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

end
