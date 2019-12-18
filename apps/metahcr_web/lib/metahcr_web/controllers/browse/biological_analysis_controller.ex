defmodule MetahcrWeb.Browse.BiologicalAnalysisController do
  use MetahcrWeb, :controller

  alias Metahcr.BiologicalAnalysis

  @doc """
  This index function will return all biological analyses associated with
  a Sample.
  """
  def index(conn, %{"page" => page, "itemcount" => item_count, "samp_id" => samp_id}) do
    {biological_analyses, count} =
      BiologicalAnalysis.list_biological_analyses_for_sample(page, item_count, samp_id)
    render(conn, :index, biological_analyses: biological_analyses, count: count)
  end
  @doc """
  This index function return item_count Samples at a database page.
  """
  def index(conn, %{"page" => page, "itemcount" => item_count}) do
    {biological_analyses, count} = BiologicalAnalysis.list_biological_analyses(page, item_count)
    render(conn, :index, biological_analyses: biological_analyses, count: count)
  end


end
