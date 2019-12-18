defmodule Metahcr.Sample do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{Sample, InvestigationSample,
      Attribute, BiologicalAnalysis, SingleGeneResult, Repo}


  schema "sample" do
    field :source_mat_id, :string
    field :samp_well_name, :string
    field :samp_description, :string
    field :samp_comment, :string
    field :samp_name, :string
    field :samp_name_alias, :string
    belongs_to :samp_type, Attribute, references: :id
    has_one :investigation_sample,  InvestigationSample
    has_one :investigation, through: [:investigation_sample, :investigation]
    has_many :analyses, BiologicalAnalysis
    # timestamps()
  end

  @doc false
  def changeset(%Sample{} = sample, attrs) do
    sample
    |> cast(attrs, [])
    |> validate_required([])
  end


  @sample_preload [:samp_type]

  def count_samples do
    query = from sample in Sample, select: count(sample.id)
    List.first(Repo.all(query))
  end

  @doc """
  Returns the list of samples.

  ## Examples

      iex> list_samples()
      [%Sample{}, ...]

  """
  def list_samples do
    Repo.all(Sample)
  end

  def list_samples(page, item_count) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page

    query = from s in Sample
    paged_query = query
            |> preload(^@sample_preload)
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from s in query, select: {count(s.id)}
    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end
  @doc """
  Select all of the Samples for an Investigation
  """
  def list_samples_for_investigation(page, item_count, inv_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_inv_id = String.to_integer inv_id
    query = from s in Sample,
              join: i_s in InvestigationSample,
              on: s.id == i_s.sample_id,
              where: i_s.investigation_id == ^i_inv_id
    paged_query = query
            |> preload(^@sample_preload)
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from s in query, select: {count(s.id)}
    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

  def list_samples_for_organisms(page, item_count, org_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_org_id = String.to_integer org_id
    q = from s in Sample
    q1 = from s in q, join: ba in BiologicalAnalysis, on: s.id == ba.sample_id
    q2 = from [s,ba] in q1, join: sgr in SingleGeneResult, on: ba.id == sgr.single_gene_analysis_id
    q3 = from [s, ba, sgr] in q2, where: sgr.organism_id == ^i_org_id

    paged_query = q3
      |> preload(^@sample_preload)
      |> limit(^i_item_count)
      |> offset(^((i_page - 1) * i_item_count))
    results = Repo.all(paged_query)
    {results, length(results)}

  end
  @doc """
  Select the Sample for a BiologicalAnalysis
  """
  def get_sample_for_biological_analysis(anal_id) do
    i_anal_id = String.to_integer anal_id

    ba_query = from b in BiologicalAnalysis,
            where: b.id == ^i_anal_id,
            select: [:sample_id]
    sample_query = from s in Sample,
            join: ba in subquery(ba_query),
            on: s.id == ba.sample_id,
            preload: ^@sample_preload
    {[Repo.one(sample_query)], 1}
  end


  @doc """
  Gets a single sample.

  Raises `Ecto.NoResultsError` if the Sample does not exist.

  ## Examples

      iex> get_sample!(123)
      %Sample{}

      iex> get_sample!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sample!(id), do: Repo.get!(Sample, id)

  @doc """
  Creates a sample.

  ## Examples

      iex> create_sample(%{field: value})
      {:ok, %Sample{}}

      iex> create_sample(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sample(attrs \\ %{}) do
    %Sample{}
    |> Sample.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sample.

  ## Examples

      iex> update_sample(sample, %{field: new_value})
      {:ok, %Sample{}}

      iex> update_sample(sample, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sample(%Sample{} = sample, attrs) do
    sample
    |> Sample.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Sample.

  ## Examples

      iex> delete_sample(sample)
      {:ok, %Sample{}}

      iex> delete_sample(sample)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sample(%Sample{} = sample) do
    Repo.delete(sample)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sample changes.

  ## Examples

      iex> change_sample(sample)
      %Ecto.Changeset{source: %Sample{}}

  """
  def change_sample(%Sample{} = sample) do
    Sample.changeset(sample, %{})
  end

end
