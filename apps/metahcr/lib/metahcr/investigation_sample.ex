defmodule Metahcr.InvestigationSample do
  use Ecto.Schema
  alias Metahcr.{Investigation, Sample}

  schema "investigation_sample" do
    belongs_to :investigation, Investigation
    belongs_to :sample, Sample
  end

end
