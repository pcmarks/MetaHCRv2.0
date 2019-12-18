defmodule MetahcrWeb.Browse.InvestigationView do
  use MetahcrWeb, :view

  alias Metahcr.{Attribute}

  def render("index.json", %{investigations: investigations, count: count}) do
    %{
      count: count,
      investigations: Enum.map(investigations, &investigation_to_json/1)
    }
  end

  def investigation_to_json(investigation) do
    %{
      id: investigation.id,
      project_name: investigation.project_name,
      experimental_factor: Attribute.value_to_json(investigation.experimental_factor),
      investigation_type: Attribute.value_to_json(investigation.investigation_type),
      submitted_to_insdc: investigation.submitted_to_insdc,
      availability: Attribute.value_to_json(investigation.availability),
      completion_date: investigation.completion_date,
      ncbi_project_id: investigation.ncbi_project_id,
      investigation_description: investigation.investigation_description,
    }
  end

end
