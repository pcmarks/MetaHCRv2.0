defmodule Metahcr.SingleGeneAnalysis do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{BiologicalAnalysis, SingleGeneAnalysis, Attribute, Repo}

  @primary_key {:biologicalanalysis_ptr_id, :id, autogenerate: false}
  schema "single_gene_analysis" do
    field :chimera_check, :string
    belongs_to :target_gene, Attribute, references: :id
    field :target_subfragment, :string
    field :pcr_primers, :string
  end

  def changeset(%SingleGeneAnalysis{} = single_gene_analysis, attrs) do
    single_gene_analysis
    |> cast(attrs, [])
    |> validate_required([])
  end

  def list_single_gene_analyses(page, item_count) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    query = from sga in SingleGeneAnalysis,
            join: ba in BiologicalAnalysis,
            on: ba.id == sga.biologicalanalysis_ptr_id,
            select: %{analysis_name: ba.analysis_name,
                      target_gene: sga.target_gene_id,
                      pcr_primers: sga.pcr_primers,
                      sample_id: ba.sample_id,
                      analysis_id: sga.biologicalanalysis_ptr_id}

    paged_query = query
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))

    count_query = from sga in SingleGeneAnalysis, select: count(sga.biologicalanalysis_ptr_id)

    results = Repo.all(paged_query)
    count = Repo.one(count_query)
    # count = Repo.aggregate(results, :count, :ba_analysis_name)
    {results, count}
  end

  def list_single_gene_analyses_for_sample(page, item_count, sample_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_sample_id = String.to_integer sample_id

    query = from sga in SingleGeneAnalysis,
            inner_join: ba in BiologicalAnalysis,
            on: ba.id == sga.biologicalanalysis_ptr_id,
            where: ba.sample_id == ^i_sample_id,
            select: %{analysis_name: ba.analysis_name,
                      target_gene: sga.target_gene_id,
                      pcr_primers: sga.pcr_primers,
                      sample_id: ba.sample_id,
                      analysis_id: sga.biologicalanalysis_ptr_id}

    paged_query = query
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))

    count_query = from ba in BiologicalAnalysis, where: ba.sample_id == ^i_sample_id, select: count(ba.id)

    results = Repo.all(paged_query)
    count = Repo.one(count_query)
    {results, count}
  end

end
