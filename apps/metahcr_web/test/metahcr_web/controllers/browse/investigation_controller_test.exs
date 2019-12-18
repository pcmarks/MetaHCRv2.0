defmodule MetahcrWeb.Browse.InvestigationControllerTest do
  use MetahcrWeb.ConnCase

  alias Metahcr.Browse

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:investigation) do
    {:ok, investigation} = Browse.create_investigation(@create_attrs)
    investigation
  end

  describe "index" do
    test "lists all investigations", %{conn: conn} do
      conn = get conn, browse_investigation_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Investigations"
    end
  end

  describe "new investigation" do
    test "renders form", %{conn: conn} do
      conn = get conn, browse_investigation_path(conn, :new)
      assert html_response(conn, 200) =~ "New Investigation"
    end
  end

  describe "create investigation" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, browse_investigation_path(conn, :create), investigation: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == browse_investigation_path(conn, :show, id)

      conn = get conn, browse_investigation_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Investigation"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, browse_investigation_path(conn, :create), investigation: @invalid_attrs
      assert html_response(conn, 200) =~ "New Investigation"
    end
  end

  describe "edit investigation" do
    setup [:create_investigation]

    test "renders form for editing chosen investigation", %{conn: conn, investigation: investigation} do
      conn = get conn, browse_investigation_path(conn, :edit, investigation)
      assert html_response(conn, 200) =~ "Edit Investigation"
    end
  end

  describe "update investigation" do
    setup [:create_investigation]

    test "redirects when data is valid", %{conn: conn, investigation: investigation} do
      conn = put conn, browse_investigation_path(conn, :update, investigation), investigation: @update_attrs
      assert redirected_to(conn) == browse_investigation_path(conn, :show, investigation)

      conn = get conn, browse_investigation_path(conn, :show, investigation)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, investigation: investigation} do
      conn = put conn, browse_investigation_path(conn, :update, investigation), investigation: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Investigation"
    end
  end

  describe "delete investigation" do
    setup [:create_investigation]

    test "deletes chosen investigation", %{conn: conn, investigation: investigation} do
      conn = delete conn, browse_investigation_path(conn, :delete, investigation)
      assert redirected_to(conn) == browse_investigation_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, browse_investigation_path(conn, :show, investigation)
      end
    end
  end

  defp create_investigation(_) do
    investigation = fixture(:investigation)
    {:ok, investigation: investigation}
  end
end
