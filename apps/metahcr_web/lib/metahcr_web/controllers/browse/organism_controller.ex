defmodule MetahcrWeb.Browse.OrganismController do
  use MetahcrWeb, :controller

  alias Metahcr.Organism

  # def index(conn, %{"page" => page, "itemcount" => item_count, "analysis_id" => analysis_id}) do
  #   {biological_analyses, count} =
  #     Browse.list_biological_analyses_for_sample(page, item_count, samp_id)
  #   render(conn, :index, biological_analyses: biological_analyses, count: count)
  # end
  def index(conn, %{"page" => page, "itemcount" => item_count}) do
    {organisms, count} = Organism.list_organisms(page, item_count)
    render(conn, :index, organisms: organisms, count: count)
  end

end
