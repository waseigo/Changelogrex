defmodule Changelogr.FetchopsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Changelogr.Fetchops` context.
  """

  @doc """
  Generate a fetchop.
  """
  def fetchop_fixture(attrs \\ %{}) do
    {:ok, fetchop} =
      attrs
      |> Enum.into(%{
        errors: "some errors",
        status: 42,
        timestamp: ~U[2023-11-19 22:17:00Z],
        url: "some url"
      })
      |> Changelogr.Fetchops.create_fetchop()

    fetchop
  end
end
