defmodule MetahcrWeb.Browse.CountView do
  use MetahcrWeb, :view

  def render("count.json",
  %{investigation_count: investigation_count,
  sample_count: sample_count,
  analysis_count: analysis_count,
  organism_count: organism_count}) do
    %{
      investigation_count: investigation_count,
      sample_count: sample_count,
      analysis_count: analysis_count,
      organism_count: organism_count
    }
  end

end
