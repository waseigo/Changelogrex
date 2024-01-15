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
      assert instruction.friendly == "some friendly"
    end

    test "create_instruction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Augmentations.create_instruction(@invalid_attrs)
    end

    test "update_instruction/2 with valid data updates the instruction" do
      instruction = instruction_fixture()
      update_attrs = %{json: false, model: "some updated model", prompt: "some updated prompt"}

      assert {:ok, %Instruction{} = instruction} =
               Augmentations.update_instruction(instruction, update_attrs)

      assert instruction.json == false
      assert instruction.model == "some updated model"
      assert instruction.prompt == "some updated prompt"
      assert instruction.friendly == "some updated friendly"
    end

    test "update_instruction/2 with invalid data returns error changeset" do
      instruction = instruction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Augmentations.update_instruction(instruction, @invalid_attrs)

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

  describe "answers" do
    alias Changelogr.Augmentations.Answer

    import Changelogr.AugmentationsFixtures

    @invalid_attrs %{model: nil, response: nil, status: nil}

    test "list_answers/0 returns all answers" do
      answer = answer_fixture()
      assert Augmentations.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Augmentations.get_answer!(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      valid_attrs = %{model: "some model", response: "some response", status: "some status"}

      assert {:ok, %Answer{} = answer} = Augmentations.create_answer(valid_attrs)
      assert answer.model == "some model"
      assert answer.response == "some response"
      assert answer.status == "some status"
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Augmentations.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()

      update_attrs = %{
        model: "some updated model",
        response: "some updated response",
        status: "some updated status"
      }

      assert {:ok, %Answer{} = answer} = Augmentations.update_answer(answer, update_attrs)
      assert answer.model == "some updated model"
      assert answer.response == "some updated response"
      assert answer.status == "some updated status"
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Augmentations.update_answer(answer, @invalid_attrs)
      assert answer == Augmentations.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Augmentations.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Augmentations.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = answer_fixture()
      assert %Ecto.Changeset{} = Augmentations.change_answer(answer)
    end
  end
end
