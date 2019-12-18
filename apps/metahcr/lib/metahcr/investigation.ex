defmodule Metahcr.Investigation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Metahcr.{Investigation, Attribute, InvestigationSample, Repo}


  schema "investigation" do
    field :project_name, :string
    # has_one :experimental_factor_id, Attribute, foreign_key: :id
    # has_one :investigation_type_id, Attribute, foreign_key: :id
    belongs_to :experimental_factor, Attribute, references: :id
    belongs_to :investigation_type, Attribute,  references: :id
    field :submitted_to_insdc, :boolean
    belongs_to :availability, Attribute, references: :id
    field :completion_date, :utc_datetime
    field :ncbi_project_id, :string
    field :investigation_description, :string
    has_many :investigation_sample, InvestigationSample
    has_many :sample, through: [:investigation_sample, :sample]

    # timestamps()
  end

  @doc false
  def changeset(%Investigation{} = investigation, attrs) do
    investigation
    |> cast(attrs, [])
    |> validate_required([])
  end

  def count_investigations do
    query = from investigation in Investigation, select: count(investigation.id)
    List.first(Repo.all(query))
  end

  @investigation_preload [:experimental_factor, :investigation_type, :availability]

  @doc """
  Returns the list of investigations.

  ## Examples

      iex> list_investigations()
      [%Investigation{}, ...]

  """
  def list_investigations do
    Repo.all(Investigation)
  end


  def list_investigations(page, item_count, samp_id) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    i_samp_id = String.to_integer samp_id

    query = from i in Investigation,
              join: i_s in InvestigationSample,
              on: i.id == i_s.investigation_id,
              where: i_s.sample_id == ^i_samp_id
    paged_query = query
            |> preload(^@investigation_preload)
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from i in query, select: {count(i.id)}
    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

  def list_investigations(page, item_count) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page

    query = from i in Investigation
    paged_query = query
            |> preload(^@investigation_preload)
            |> limit(^i_item_count)
            |> offset(^((i_page - 1) * i_item_count))
    count_query = from i in query, select: {count(i.id)}

    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

  def filter_investigations(page, item_count, col, val) do
    i_item_count = String.to_integer item_count
    i_page = String.to_integer page
    a_col = String.to_atom(col)
    query = from i in Investigation,
              where: ilike(field(i, ^a_col), ^"%#{val}%")
    paged_query = query
                  |> preload(^@investigation_preload)
                  |> limit(^i_item_count)
                  |> offset(^((i_page - 1) * i_item_count))
    count_query = from i in query, select: {count(i.id)}

    results = Repo.all(paged_query)
    {count} = Repo.one(count_query)
    {results, count}
  end

  @doc """
  Gets a single investigation.

  Raises `Ecto.NoResultsError` if the Investigation does not exist.

  ## Examples

      iex> get_investigation!(123)
      %Investigation{}

      iex> get_investigation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_investigation!(id) do
    query = from i in Investigation,
      where: i.id == ^id,
      preload: ^@investigation_preload
    Repo.all(query)
  end
     # Repo.get!(Investigation, id)

  @doc """
  Creates a investigation.

  ## Examples

      iex> create_investigation(%{field: value})
      {:ok, %Investigation{}}

      iex> create_investigation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_investigation(attrs \\ %{}) do
    %Investigation{}
    |> Investigation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a investigation.

  ## Examples

      iex> update_investigation(investigation, %{field: new_value})
      {:ok, %Investigation{}}

      iex> update_investigation(investigation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_investigation(%Investigation{} = investigation, attrs) do
    investigation
    |> Investigation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Investigation.

  ## Examples

      iex> delete_investigation(investigation)
      {:ok, %Investigation{}}

      iex> delete_investigation(investigation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_investigation(%Investigation{} = investigation) do
    Repo.delete(investigation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking investigation changes.

  ## Examples

      iex> change_investigation(investigation)
      %Ecto.Changeset{source: %Investigation{}}

  """
  def change_investigation(%Investigation{} = investigation) do
    Investigation.changeset(investigation, %{})
  end


end
