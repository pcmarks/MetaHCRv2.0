defmodule MetahcrWeb.Browse.SingleGeneResultController do
  use MetahcrWeb, :controller

  alias Metahcr.SingleGeneResult

  @doc """
  This index function will return all single gene results associated with
  an analysis.
  """
  def index(conn, %{"page" => page, "itemcount" => item_count, "analysis_id" => analysis_id}) do
    {single_gene_results, count} =
      SingleGeneResult.list_results_for_analysis(page, item_count, analysis_id)
    render(conn, :index, single_gene_results: single_gene_results, count: count)
  end


end
