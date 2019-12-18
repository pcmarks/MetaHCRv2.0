defmodule MetahcrWeb.Browse.SampleControllerTest do
  use MetahcrWeb.ConnCase

  alias Metahcr.Browse

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:sample) do
    {:ok, sample} = Browse.create_sample(@create_attrs)
    sample
  end

  describe "index" do
    test "lists all samples", %{conn: conn} do
      conn = get conn, browse_sample_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Samples"
    end
  end

  describe "new sample" do
    test "renders form", %{conn: conn} do
      conn = get conn, browse_sample_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sample"
    end
  end

  describe "create sample" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, browse_sample_path(conn, :create), sample: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == browse_sample_path(conn, :show, id)

      conn = get conn, browse_sample_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sample"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, browse_sample_path(conn, :create), sample: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sample"
    end
  end

  describe "edit sample" do
    setup [:create_sample]

    test "renders form for editing chosen sample", %{conn: conn, sample: sample} do
      conn = get conn, browse_sample_path(conn, :edit, sample)
      assert html_response(conn, 200) =~ "Edit Sample"
    end
  end

  describe "update sample" do
    setup [:create_sample]

    test "redirects when data is valid", %{conn: conn, sample: sample} do
      conn = put conn, browse_sample_path(conn, :update, sample), sample: @update_attrs
      assert redirected_to(conn) == browse_sample_path(conn, :show, sample)

      conn = get conn, browse_sample_path(conn, :show, sample)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, sample: sample} do
      conn = put conn, browse_sample_path(conn, :update, sample), sample: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sample"
    end
  end

  describe "delete sample" do
    setup [:create_sample]

    test "deletes chosen sample", %{conn: conn, sample: sample} do
      conn = delete conn, browse_sample_path(conn, :delete, sample)
      assert redirected_to(conn) == browse_sample_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, browse_sample_path(conn, :show, sample)
      end
    end
  end

  defp create_sample(_) do
    sample = fixture(:sample)
    {:ok, sample: sample}
  end
end
