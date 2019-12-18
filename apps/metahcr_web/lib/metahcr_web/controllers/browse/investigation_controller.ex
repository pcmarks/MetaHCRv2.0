defmodule MetahcrWeb.Browse.InvestigationController do
  use MetahcrWeb, :controller

  alias Metahcr.Investigation

  def index(conn, %{"page" => page, "itemcount" => itemcount, "samp_id" => samp_id}) do
    {investigations, count} = Investigation.list_investigations(page, itemcount, samp_id)
    render(conn, :index, investigations: investigations, count: count)
  end

  def index(conn, %{"page" => page, "itemcount" => itemcount,
                    "col" => col, "val" => val}) do
    {investigations, count} = Investigation.filter_investigations(page, itemcount, col, val )
    render(conn, :index, investigations: investigations, count: count)
  end

  def index(conn, %{"page" => page, "itemcount" => itemcount}) do
    {investigations, count} = Investigation.list_investigations(page, itemcount)
    render(conn, :index, investigations: investigations, count: count)
  end

  def new(conn, _params) do
    changeset = Investigation.change_investigation(%Investigation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"investigation" => investigation_params}) do
    case Investigation.create_investigation(investigation_params) do
      {:ok, investigation} ->
        conn
        |> put_flash(:info, "Investigation created successfully.")
        |> redirect(to: browse_investigation_path(conn, :show, investigation))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    investigation = Investigation.get_investigation!(id)
    render(conn, :show, investigation: investigation)
  end

  def edit(conn, %{"id" => id}) do
    investigation = Investigation.get_investigation!(id)
    changeset = Investigation.change_investigation(investigation)
    render(conn, "edit.html", investigation: investigation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "investigation" => investigation_params}) do
    investigation = Investigation.get_investigation!(id)

    case Investigation.update_investigation(investigation, investigation_params) do
      {:ok, investigation} ->
        conn
        |> put_flash(:info, "Investigation updated successfully.")
        |> redirect(to: browse_investigation_path(conn, :show, investigation))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", investigation: investigation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    investigation = Investigation.get_investigation!(id)
    {:ok, _investigation} = Investigation.delete_investigation(investigation)

    conn
    |> put_flash(:info, "Investigation deleted successfully.")
    |> redirect(to: browse_investigation_path(conn, :index))
  end
end
