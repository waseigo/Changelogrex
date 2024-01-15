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

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        model: "some model",
        response: "some response",
        status: "some status"
      })
      |> Changelogr.Augmentations.create_answer()

    answer
  end
end
