defmodule Metahcr.BiologicalAnalysis do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{Attribute, BiologicalAnalysis, Sample, SingleGeneAnalysis, Repo}

  schema "biological_analysis" do
    field :analysis_name, :string
    field :samp_anal_name, :string
    belongs_to :type, Attribute, references: :id
    belongs_to :sample, Sample
    belongs_to :single_gene_analysis_id, SingleGeneAnalysis
  end

  @doc false
  def changeset(%BiologicalAnalysis{} = analysis, attrs) do
    analysis
    |> cast(attrs, [])
    |> validate_required([])
  end

  def count_analyses do
    query = from ba in BiologicalAnalysis, select: count(ba.id)
    List.first(Repo.all(query))
  end

  @doc """
  List all of the BiologicalAnalyses
  """
  @biological_analysis_preload [:type]
  def list_biological_analyses(page, item_count) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page

    query = from ba in BiologicalAnalysis
    paged_query = query
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
            |> preload(^@biological_analysis_preload)
    count_query = from b in query, select: {count(b.id)}

    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

  def list_biological_analyses_for_sample(page, item_count, sample_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_sample_id = String.to_integer sample_id

    query = from b in BiologicalAnalysis,
            where: b.sample_id == ^i_sample_id
    paged_query = query
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
            |> preload(^@biological_analysis_preload)
    count_query = from b in query, select: {count(b.id)}

    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

end
