defmodule MetahcrWeb.Browse.SingleGeneAnalysisView do
  use MetahcrWeb, :view
  alias Metahcr.{Attribute}

  def render("index.json", %{single_gene_analyses: single_gene_analyses, count: count}) do
                %{count: count,
                  single_gene_analyses: Enum.map(single_gene_analyses,
                    &single_gene_analysis_to_json/1)
                  }
  end

  def single_gene_analysis_to_json(sga) do
    %{
      analysis_id: sga.analysis_id,
      analysis_name: sga.analysis_name,
      target_gene: Attribute.value_to_json(Attribute.get_attribute!(sga.target_gene)),
      pcr_primers: sga.pcr_primers,
      sample_id: sga.sample_id
    }
  end
end
