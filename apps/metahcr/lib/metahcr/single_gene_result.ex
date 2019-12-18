defmodule Metahcr.SingleGeneResult do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{SingleGeneAnalysis, SingleGeneResult, Organism, Attribute, Repo}

  schema "single_gene_result" do
    belongs_to :organism, Organism, references: :id
    field :score, :decimal
    belongs_to :single_gene_analysis, SingleGeneAnalysis, references: :id
  end

  def list_results_for_analysis(page, item_count, analysis_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_analysis_id = String.to_integer analysis_id

    query = from r in SingleGeneResult,
            where: r.single_gene_analysis_id == ^i_analysis_id,
            order_by: [desc: :score],
            preload: [:organism]
    paged_query = query
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from sgr in SingleGeneResult,
            where: sgr.single_gene_analysis_id == ^i_analysis_id,
            select: count(sgr.id)

    results = Repo.all(paged_query)
    count = Repo.one(count_query)
    {results, count}
  end
end
