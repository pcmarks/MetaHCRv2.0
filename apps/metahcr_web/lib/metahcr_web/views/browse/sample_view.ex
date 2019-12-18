defmodule MetahcrWeb.Browse.SampleView do
  use MetahcrWeb, :view

  alias Metahcr.{Attribute}

  def render("index.json", %{samples: samples, count: count}) do
    %{
      count: count,
      samples: Enum.map(samples, &sample_to_json/1)
    }
  end


  def render("show.json", %{sample: sample}) do
    sample_to_json(sample)
  end

  def sample_to_json(sample) do
    %{
      id: sample.id,
      source_mat_id: sample.source_mat_id,
      samp_description: sample.samp_description,
      samp_comment: sample.samp_comment,
      samp_name: sample.samp_name,
      samp_type: Attribute.value_to_json(sample.samp_type)
    }
  end
end
