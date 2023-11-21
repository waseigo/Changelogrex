defmodule Changelogr.KernelsTest do
  use Changelogr.DataCase

  alias Changelogr.Kernels

  describe "changelogs" do
    alias Changelogr.Kernels.Changelog

    import Changelogr.KernelsFixtures

    @invalid_attrs %{date: nil, kernel_version: nil, timestamp: nil, url: nil}

    test "list_changelogs/0 returns all changelogs" do
      changelog = changelog_fixture()
      assert Kernels.list_changelogs() == [changelog]
    end

    test "get_changelog!/1 returns the changelog with given id" do
      changelog = changelog_fixture()
      assert Kernels.get_changelog!(changelog.id) == changelog
    end

    test "create_changelog/1 with valid data creates a changelog" do
      valid_attrs = %{
        date: ~N[2023-11-19 20:49:00],
        kernel_version: "some kernel_version",
        timestamp: ~U[2023-11-19 20:49:00Z],
        url: "some url"
      }

      assert {:ok, %Changelog{} = changelog} = Kernels.create_changelog(valid_attrs)
      assert changelog.date == ~N[2023-11-19 20:49:00]
      assert changelog.kernel_version == "some kernel_version"
      assert changelog.timestamp == ~U[2023-11-19 20:49:00Z]
      assert changelog.url == "some url"
    end

    test "create_changelog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Kernels.create_changelog(@invalid_attrs)
    end

    test "update_changelog/2 with valid data updates the changelog" do
      changelog = changelog_fixture()

      update_attrs = %{
        date: ~N[2023-11-20 20:49:00],
        kernel_version: "some updated kernel_version",
        timestamp: ~U[2023-11-20 20:49:00Z],
        url: "some updated url"
      }

      assert {:ok, %Changelog{} = changelog} = Kernels.update_changelog(changelog, update_attrs)
      assert changelog.date == ~N[2023-11-20 20:49:00]
      assert changelog.kernel_version == "some updated kernel_version"
      assert changelog.timestamp == ~U[2023-11-20 20:49:00Z]
      assert changelog.url == "some updated url"
    end

    test "update_changelog/2 with invalid data returns error changeset" do
      changelog = changelog_fixture()
      assert {:error, %Ecto.Changeset{}} = Kernels.update_changelog(changelog, @invalid_attrs)
      assert changelog == Kernels.get_changelog!(changelog.id)
    end

    test "delete_changelog/1 deletes the changelog" do
      changelog = changelog_fixture()
      assert {:ok, %Changelog{}} = Kernels.delete_changelog(changelog)
      assert_raise Ecto.NoResultsError, fn -> Kernels.get_changelog!(changelog.id) end
    end

    test "change_changelog/1 returns a changelog changeset" do
      changelog = changelog_fixture()
      assert %Ecto.Changeset{} = Kernels.change_changelog(changelog)
    end
  end
end
