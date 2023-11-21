defmodule Changelogr.FetchopsTest do
  use Changelogr.DataCase

  alias Changelogr.Fetchops

  describe "fetchops" do
    alias Changelogr.Fetchops.Fetchop

    import Changelogr.FetchopsFixtures

    @invalid_attrs %{errors: nil, status: nil, timestamp: nil, url: nil}

    test "list_fetchops/0 returns all fetchops" do
      fetchop = fetchop_fixture()
      assert Fetchops.list_fetchops() == [fetchop]
    end

    test "get_fetchop!/1 returns the fetchop with given id" do
      fetchop = fetchop_fixture()
      assert Fetchops.get_fetchop!(fetchop.id) == fetchop
    end

    test "create_fetchop/1 with valid data creates a fetchop" do
      valid_attrs = %{
        errors: "some errors",
        status: 42,
        timestamp: ~U[2023-11-19 22:17:00Z],
        url: "some url"
      }

      assert {:ok, %Fetchop{} = fetchop} = Fetchops.create_fetchop(valid_attrs)
      assert fetchop.errors == "some errors"
      assert fetchop.status == 42
      assert fetchop.timestamp == ~U[2023-11-19 22:17:00Z]
      assert fetchop.url == "some url"
    end

    test "create_fetchop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fetchops.create_fetchop(@invalid_attrs)
    end

    test "update_fetchop/2 with valid data updates the fetchop" do
      fetchop = fetchop_fixture()

      update_attrs = %{
        errors: "some updated errors",
        status: 43,
        timestamp: ~U[2023-11-20 22:17:00Z],
        url: "some updated url"
      }

      assert {:ok, %Fetchop{} = fetchop} = Fetchops.update_fetchop(fetchop, update_attrs)
      assert fetchop.errors == "some updated errors"
      assert fetchop.status == 43
      assert fetchop.timestamp == ~U[2023-11-20 22:17:00Z]
      assert fetchop.url == "some updated url"
    end

    test "update_fetchop/2 with invalid data returns error changeset" do
      fetchop = fetchop_fixture()
      assert {:error, %Ecto.Changeset{}} = Fetchops.update_fetchop(fetchop, @invalid_attrs)
      assert fetchop == Fetchops.get_fetchop!(fetchop.id)
    end

    test "delete_fetchop/1 deletes the fetchop" do
      fetchop = fetchop_fixture()
      assert {:ok, %Fetchop{}} = Fetchops.delete_fetchop(fetchop)
      assert_raise Ecto.NoResultsError, fn -> Fetchops.get_fetchop!(fetchop.id) end
    end

    test "change_fetchop/1 returns a fetchop changeset" do
      fetchop = fetchop_fixture()
      assert %Ecto.Changeset{} = Fetchops.change_fetchop(fetchop)
    end
  end
end
