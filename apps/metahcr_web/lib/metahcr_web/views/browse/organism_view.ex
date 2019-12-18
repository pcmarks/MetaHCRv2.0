defmodule MetahcrWeb.Browse.OrganismView do
  use MetahcrWeb, :view

  def render("index.json", %{organisms: organisms, count: count}) do
    %{
      count: count,
      organisms: Enum.map(organisms, &organism_to_json/1)
    }
  end
  def organism_to_json(organism) do
    %{
      id: organism.id ,
      superkingdom: organism.superkingdom,
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
