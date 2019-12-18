defmodule Metahcr.BrowseTest do
  use Metahcr.DataCase

  alias Metahcr.Browse

  describe "investigations" do
    alias Metahcr.Browse.Investigation

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def investigation_fixture(attrs \\ %{}) do
      {:ok, investigation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Browse.create_investigation()

      investigation
    end

    test "list_investigations/0 returns all investigations" do
      investigation = investigation_fixture()
      assert Browse.list_investigations() == [investigation]
    end

    test "get_investigation!/1 returns the investigation with given id" do
      investigation = investigation_fixture()
      assert Browse.get_investigation!(investigation.id) == investigation
    end

    test "create_investigation/1 with valid data creates a investigation" do
      assert {:ok, %Investigation{} = investigation} = Browse.create_investigation(@valid_attrs)
    end

    test "create_investigation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Browse.create_investigation(@invalid_attrs)
    end

    test "update_investigation/2 with valid data updates the investigation" do
      investigation = investigation_fixture()
      assert {:ok, investigation} = Browse.update_investigation(investigation, @update_attrs)
      assert %Investigation{} = investigation
    end

    test "update_investigation/2 with invalid data returns error changeset" do
      investigation = investigation_fixture()
      assert {:error, %Ecto.Changeset{}} = Browse.update_investigation(investigation, @invalid_attrs)
      assert investigation == Browse.get_investigation!(investigation.id)
    end

    test "delete_investigation/1 deletes the investigation" do
      investigation = investigation_fixture()
      assert {:ok, %Investigation{}} = Browse.delete_investigation(investigation)
      assert_raise Ecto.NoResultsError, fn -> Browse.get_investigation!(investigation.id) end
    end

    test "change_investigation/1 returns a investigation changeset" do
      investigation = investigation_fixture()
      assert %Ecto.Changeset{} = Browse.change_investigation(investigation)
    end
  end

  describe "samples" do
    alias Metahcr.Browse.Sample

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def sample_fixture(attrs \\ %{}) do
      {:ok, sample} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Browse.create_sample()

      sample
    end

    test "list_samples/0 returns all samples" do
      sample = sample_fixture()
      assert Browse.list_samples() == [sample]
    end

    test "get_sample!/1 returns the sample with given id" do
      sample = sample_fixture()
      assert Browse.get_sample!(sample.id) == sample
    end

    test "create_sample/1 with valid data creates a sample" do
      assert {:ok, %Sample{} = sample} = Browse.create_sample(@valid_attrs)
    end

    test "create_sample/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Browse.create_sample(@invalid_attrs)
    end

    test "update_sample/2 with valid data updates the sample" do
      sample = sample_fixture()
      assert {:ok, sample} = Browse.update_sample(sample, @update_attrs)
      assert %Sample{} = sample
    end

    test "update_sample/2 with invalid data returns error changeset" do
      sample = sample_fixture()
      assert {:error, %Ecto.Changeset{}} = Browse.update_sample(sample, @invalid_attrs)
      assert sample == Browse.get_sample!(sample.id)
    end

    test "delete_sample/1 deletes the sample" do
      sample = sample_fixture()
      assert {:ok, %Sample{}} = Browse.delete_sample(sample)
      assert_raise Ecto.NoResultsError, fn -> Browse.get_sample!(sample.id) end
    end

    test "change_sample/1 returns a sample changeset" do
      sample = sample_fixture()
      assert %Ecto.Changeset{} = Browse.change_sample(sample)
    end
  end

  describe "attributes" do
    alias Metahcr.Browse.Attribute

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def attribute_fixture(attrs \\ %{}) do
      {:ok, attribute} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Browse.create_attribute()

      attribute
    end

    test "list_attributes/0 returns all attributes" do
      attribute = attribute_fixture()
      assert Browse.list_attributes() == [attribute]
    end

    test "get_attribute!/1 returns the attribute with given id" do
      attribute = attribute_fixture()
      assert Browse.get_attribute!(attribute.id) == attribute
    end

    test "create_attribute/1 with valid data creates a attribute" do
      assert {:ok, %Attribute{} = attribute} = Browse.create_attribute(@valid_attrs)
    end

    test "create_attribute/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Browse.create_attribute(@invalid_attrs)
    end

    test "update_attribute/2 with valid data updates the attribute" do
      attribute = attribute_fixture()
      assert {:ok, attribute} = Browse.update_attribute(attribute, @update_attrs)
      assert %Attribute{} = attribute
    end

    test "update_attribute/2 with invalid data returns error changeset" do
      attribute = attribute_fixture()
      assert {:error, %Ecto.Changeset{}} = Browse.update_attribute(attribute, @invalid_attrs)
      assert attribute == Browse.get_attribute!(attribute.id)
    end

    test "delete_attribute/1 deletes the attribute" do
      attribute = attribute_fixture()
      assert {:ok, %Attribute{}} = Browse.delete_attribute(attribute)
      assert_raise Ecto.NoResultsError, fn -> Browse.get_attribute!(attribute.id) end
    end

    test "change_attribute/1 returns a attribute changeset" do
      attribute = attribute_fixture()
      assert %Ecto.Changeset{} = Browse.change_attribute(attribute)
    end
  end
end
