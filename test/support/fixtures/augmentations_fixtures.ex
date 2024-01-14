defmodule Changelogr.AugmentationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Changelogr.Augmentations` context.
  """

  @doc """
  Generate a instruction.
  """
  def instruction_fixture(attrs \\ %{}) do
    {:ok, instruction} =
      attrs
      |> Enum.into(%{
        json: true,
        model: "some model",
        prompt: "some prompt"
      })
      |> Changelogr.Augmentations.create_instruction()

    instruction
  end
end
