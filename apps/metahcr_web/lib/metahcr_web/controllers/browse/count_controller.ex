defmodule MetahcrWeb.Browse.CountController do
  use MetahcrWeb, :controller

  alias Metahcr.{Investigation, Sample, BiologicalAnalysis, Organism}

  def count_all(conn, _params) do
    # case authenticate(conn) do
    #   %Plug.Conn{halted: true} = conn ->
    #     conn
    #   conn -> conn
    #     # redirect(conn, to: count_path(conn, :index))
    #   end
    investigation_count = Investigation.count_investigations
    sample_count = Sample.count_samples
    analysis_count = BiologicalAnalysis.count_analyses
    organism_count = Organism.count_organisms
    render(conn, "count.json",
      investigation_count: investigation_count,
      sample_count: sample_count,
      analysis_count: analysis_count,
      organism_count: organism_count)
  end

  defp authenticate(conn) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end
