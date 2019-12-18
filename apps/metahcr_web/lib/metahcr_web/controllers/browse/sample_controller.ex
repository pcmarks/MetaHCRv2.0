defmodule MetahcrWeb.Browse.SampleController do
  use MetahcrWeb, :controller

  alias Metahcr.Sample

  def index(conn, %{"anal_id" => anal_id}) do
    {samples, count} =
      Sample.get_sample_for_biological_analysis(anal_id)
    render(conn, :index, samples: samples, count: count)
  end
  def index(conn, %{"page" => page, "itemcount" => item_count, "inv_id" => inv_id}) do
    {samples, count} =
      Sample.list_samples_for_investigation(page, item_count, inv_id)
    render(conn, :index, samples: samples, count: count)
  end

  def index(conn, %{"page" => page, "itemcount" => item_count, "organism_id" => org_id}) do
    {samples, count} =
      Sample.list_samples_for_organisms(page, item_count, org_id)
    render(conn, :index, samples: samples, count: count)
  end

  def index(conn, %{"page" => page, "itemcount" => item_count}) do
    {samples, count} = Sample.list_samples(page, item_count)
    render(conn, :index, samples: samples, count: count)
  end


  def show(conn, %{"id" => id}) do
    sample = Sample.get_sample!(id)
    render(conn, :show, sample: sample)
  end


  def new(conn, _params) do
    changeset = Sample.change_sample(%Sample{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sample" => sample_params}) do
    case Sample.create_sample(sample_params) do
      {:ok, sample} ->
        conn
        |> put_flash(:info, "Sample created successfully.")
        |> redirect(to: browse_sample_path(conn, :show, sample))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    sample = Sample.get_sample!(id)
    changeset = Sample.change_sample(sample)
    render(conn, "edit.html", sample: sample, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sample" => sample_params}) do
    sample = Sample.get_sample!(id)

    case Sample.update_sample(sample, sample_params) do
      {:ok, sample} ->
        conn
        |> put_flash(:info, "Sample updated successfully.")
        |> redirect(to: browse_sample_path(conn, :show, sample))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sample: sample, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sample = Sample.get_sample!(id)
    {:ok, _sample} = Sample.delete_sample(sample)

    conn
    |> put_flash(:info, "Sample deleted successfully.")
    |> redirect(to: browse_sample_path(conn, :index))
  end
end
