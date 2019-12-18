defmodule MetahcrWeb.Browse.SingleGeneAnalysisController do
  use MetahcrWeb, :controller

  alias Metahcr.SingleGeneAnalysis
  @doc """
  This index function will return all single gene analyses associated with
  a Sample.
  """
  def index(conn, %{"page" => page, "itemcount" => item_count, "samp_id" => samp_id}) do
    {single_gene_analyses, count} =
      SingleGeneAnalysis.list_single_gene_analyses_for_sample(page, item_count, samp_id)
    render(conn, :index, single_gene_analyses: single_gene_analyses, count: count)
  end
  @doc """
  This index function return item_count Single Gene Analyses at a database page.
  """
  def index(conn, %{"page" => page, "itemcount" => item_count}) do
    {single_gene_analyses, count} =
      SingleGeneAnalysis.list_single_gene_analyses(page, item_count)
    render(conn, :index, single_gene_analyses: single_gene_analyses, count: count)
  end
end
