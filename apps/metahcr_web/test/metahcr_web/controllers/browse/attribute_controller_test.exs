defmodule MetahcrWeb.Browse.AttributeControllerTest do
  use MetahcrWeb.ConnCase

  alias Metahcr.Browse

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:attribute) do
    {:ok, attribute} = Browse.create_attribute(@create_attrs)
    attribute
  end

  describe "index" do
    test "lists all attributes", %{conn: conn} do
      conn = get conn, browse_attribute_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Attributes"
    end
  end

  describe "new attribute" do
    test "renders form", %{conn: conn} do
      conn = get conn, browse_attribute_path(conn, :new)
      assert html_response(conn, 200) =~ "New Attribute"
    end
  end

  describe "create attribute" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, browse_attribute_path(conn, :create), attribute: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == browse_attribute_path(conn, :show, id)

      conn = get conn, browse_attribute_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Attribute"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, browse_attribute_path(conn, :create), attribute: @invalid_attrs
      assert html_response(conn, 200) =~ "New Attribute"
    end
  end

  describe "edit attribute" do
    setup [:create_attribute]

    test "renders form for editing chosen attribute", %{conn: conn, attribute: attribute} do
      conn = get conn, browse_attribute_path(conn, :edit, attribute)
      assert html_response(conn, 200) =~ "Edit Attribute"
    end
  end

  describe "update attribute" do
    setup [:create_attribute]

    test "redirects when data is valid", %{conn: conn, attribute: attribute} do
      conn = put conn, browse_attribute_path(conn, :update, attribute), attribute: @update_attrs
      assert redirected_to(conn) == browse_attribute_path(conn, :show, attribute)

      conn = get conn, browse_attribute_path(conn, :show, attribute)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, attribute: attribute} do
      conn = put conn, browse_attribute_path(conn, :update, attribute), attribute: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Attribute"
    end
  end

  describe "delete attribute" do
    setup [:create_attribute]

    test "deletes chosen attribute", %{conn: conn, attribute: attribute} do
      conn = delete conn, browse_attribute_path(conn, :delete, attribute)
      assert redirected_to(conn) == browse_attribute_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, browse_attribute_path(conn, :show, attribute)
      end
    end
  end

  defp create_attribute(_) do
    attribute = fixture(:attribute)
    {:ok, attribute: attribute}
  end
end
