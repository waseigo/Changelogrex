defmodule Changelogr.AugmentationsTest do
  use Changelogr.DataCase

  alias Changelogr.Augmentations

  describe "instructions" do
    alias Changelogr.Augmentations.Instruction

    import Changelogr.AugmentationsFixtures

    @invalid_attrs %{json: nil, model: nil, prompt: nil}

    test "list_instructions/0 returns all instructions" do
      instruction = instruction_fixture()
      assert Augmentations.list_instructions() == [instruction]
    end

    test "get_instruction!/1 returns the instruction with given id" do
      instruction = instruction_fixture()
      assert Augmentations.get_instruction!(instruction.id) == instruction
    end

    test "create_instruction/1 with valid data creates a instruction" do
      valid_attrs = %{json: true, model: "some model", prompt: "some prompt"}

      assert {:ok, %Instruction{} = instruction} = Augmentations.create_instruction(valid_attrs)
      assert instruction.json == true
      assert instruction.model == "some model"
      assert instruction.prompt == "some prompt"
    end

    test "create_instruction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Augmentations.create_instruction(@invalid_attrs)
    end

    test "update_instruction/2 with valid data updates the instruction" do
      instruction = instruction_fixture()
      update_attrs = %{json: false, model: "some updated model", prompt: "some updated prompt"}

      assert {:ok, %Instruction{} = instruction} = Augmentations.update_instruction(instruction, update_attrs)
      assert instruction.json == false
      assert instruction.model == "some updated model"
      assert instruction.prompt == "some updated prompt"
    end

    test "update_instruction/2 with invalid data returns error changeset" do
      instruction = instruction_fixture()
      assert {:error, %Ecto.Changeset{}} = Augmentations.update_instruction(instruction, @invalid_attrs)
      assert instruction == Augmentations.get_instruction!(instruction.id)
    end

    test "delete_instruction/1 deletes the instruction" do
      instruction = instruction_fixture()
      assert {:ok, %Instruction{}} = Augmentations.delete_instruction(instruction)
      assert_raise Ecto.NoResultsError, fn -> Augmentations.get_instruction!(instruction.id) end
    end

    test "change_instruction/1 returns a instruction changeset" do
      instruction = instruction_fixture()
      assert %Ecto.Changeset{} = Augmentations.change_instruction(instruction)
    end
  end
end
