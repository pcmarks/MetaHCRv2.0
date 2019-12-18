defmodule MetahcrWeb.Browse.BiologicalAnalysisView do
  use MetahcrWeb, :view
  alias Metahcr.{Attribute}

  def render("index.json", %{biological_analyses: biological_analyses, count: count}) do
    %{
      count: count,
      biological_analyses: Enum.map(biological_analyses, &biological_analysis_to_json/1)
    }
  end
  def biological_analysis_to_json(biological_analysis) do
    %{
      id: biological_analysis.id,
      analysis_name: biological_analysis.analysis_name,
      samp_anal_name: biological_analysis.samp_anal_name,
      type: Attribute.value_to_json(biological_analysis.type)
    }
  end

end
