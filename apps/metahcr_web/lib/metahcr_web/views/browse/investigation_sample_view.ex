defmodule MetahcrWeb.Browse.InvestigationSampleView do
  use MetahcrWeb, :view

  def render(json, parms) do
    MetahcrWeb.Browse.SampleView.render(json, parms)
  end

end
