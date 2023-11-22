defmodule Changelogr.CommitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Changelogr.Commits` context.
  """

  @doc """
  Generate a commit.
  """
  def commit_fixture(attrs \\ %{}) do
    {:ok, commit} =
      attrs
      |> Enum.into(%{
        body: "some body",
        commit: "some commit"
      })
      |> Changelogr.Commits.create_commit()

    commit
  end
end
