defmodule MetahcrWeb.Browse.AttributeController do
  use MetahcrWeb, :controller

  alias Metahcr.Attribute

  def index(conn, _params) do
    attributes = Attribute.list_attributes()
    render(conn, "index.html", attributes: attributes)
  end

  def new(conn, _params) do
    changeset = Attribute.change_attribute(%Attribute{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attribute" => attribute_params}) do
    case Attribute.create_attribute(attribute_params) do
      {:ok, attribute} ->
        conn
        |> put_flash(:info, "Attribute created successfully.")
        |> redirect(to: browse_attribute_path(conn, :show, attribute))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attribute = Attribute.get_attribute!(id)
    render(conn, "show.html", attribute: attribute)
  end

  def edit(conn, %{"id" => id}) do
    attribute = Attribute.get_attribute!(id)
    changeset = Attribute.change_attribute(attribute)
    render(conn, "edit.html", attribute: attribute, changeset: changeset)
  end

  def update(conn, %{"id" => id, "attribute" => attribute_params}) do
    attribute = Attribute.get_attribute!(id)

    case Attribute.update_attribute(attribute, attribute_params) do
      {:ok, attribute} ->
        conn
        |> put_flash(:info, "Attribute updated successfully.")
        |> redirect(to: browse_attribute_path(conn, :show, attribute))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", attribute: attribute, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    attribute = Attribute.get_attribute!(id)
    {:ok, _attribute} = Attribute.delete_attribute(attribute)

    conn
    |> put_flash(:info, "Attribute deleted successfully.")
    |> redirect(to: browse_attribute_path(conn, :index))
  end
end
