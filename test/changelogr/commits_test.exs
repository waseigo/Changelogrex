defmodule Changelogr.CommitsTest do
  use Changelogr.DataCase

  alias Changelogr.Commits

  describe "commits" do
    alias Changelogr.Commits.Commit

    import Changelogr.CommitsFixtures

    @invalid_attrs %{body: nil, commit: nil}

    test "list_commits/0 returns all commits" do
      commit = commit_fixture()
      assert Commits.list_commits() == [commit]
    end

    test "get_commit!/1 returns the commit with given id" do
      commit = commit_fixture()
      assert Commits.get_commit!(commit.id) == commit
    end

    test "create_commit/1 with valid data creates a commit" do
      valid_attrs = %{body: "some body", commit: "some commit"}

      assert {:ok, %Commit{} = commit} = Commits.create_commit(valid_attrs)
      assert commit.body == "some body"
      assert commit.commit == "some commit"
    end

    test "create_commit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Commits.create_commit(@invalid_attrs)
    end

    test "update_commit/2 with valid data updates the commit" do
      commit = commit_fixture()
      update_attrs = %{body: "some updated body", commit: "some updated commit"}

      assert {:ok, %Commit{} = commit} = Commits.update_commit(commit, update_attrs)
      assert commit.body == "some updated body"
      assert commit.commit == "some updated commit"
    end

    test "update_commit/2 with invalid data returns error changeset" do
      commit = commit_fixture()
      assert {:error, %Ecto.Changeset{}} = Commits.update_commit(commit, @invalid_attrs)
      assert commit == Commits.get_commit!(commit.id)
    end

    test "delete_commit/1 deletes the commit" do
      commit = commit_fixture()
      assert {:ok, %Commit{}} = Commits.delete_commit(commit)
      assert_raise Ecto.NoResultsError, fn -> Commits.get_commit!(commit.id) end
    end

    test "change_commit/1 returns a commit changeset" do
      commit = commit_fixture()
      assert %Ecto.Changeset{} = Commits.change_commit(commit)
    end
  end
end
