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
        date: ~N[2023-11-19 20:49:00],
        kernel_version: "some kernel_version",
        timestamp: ~U[2023-11-19 20:49:00Z],
        url: "some url"
      })
      |> Changelogr.Kernels.create_changelog()

    changelog
  end
end
