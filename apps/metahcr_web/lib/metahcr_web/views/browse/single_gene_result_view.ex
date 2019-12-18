defmodule MetahcrWeb.Browse.SingleGeneResultView do
  use MetahcrWeb, :view

  def render("index.json", %{single_gene_results: single_gene_results, count: count}) do
    %{count: count,
      single_gene_results: Enum.map(single_gene_results,
              &single_gene_result_to_json/1)}
  end

  def single_gene_result_to_json(%{organism: organism} = sgr) do
    %{
      organism_id: organism.id,
      score: sgr.score,
      phylum: organism.phylum,
      subphylum: organism.subphylum,
      bio_class: organism.bio_class,
      bio_order: organism.bio_order,
      family: organism.family,
      genus: organism.genus,
      species: organism.species
    }
  end
end
