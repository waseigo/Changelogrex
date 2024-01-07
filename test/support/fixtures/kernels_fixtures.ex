defmodule Changelogr.KernelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Changelogr.Kernels` context.
  """

  @doc """
  Generate a changelog.
  """
  def changelog_fixture(attrs \\ %{}) do
    {:ok, changelog} =
      attrs
      |> Enum.into(%{
        id: "6.5.9",
        date: ~N[2023-11-19 20:49:00],
        timestamp: ~U[2023-11-19 20:49:00Z],
        url: "https://...."
      })
      |> Changelogr.Kernels.create_changelog()

    changelog
  end
end
