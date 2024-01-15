defmodule Changelogr.Augmentations do
  @moduledoc """
  The Augmentations context.
  """

  import Ecto.Query, warn: false
  alias Changelogr.Repo

  alias Changelogr.Augmentations.Instruction

  @doc """
  Returns the list of instructions.

  ## Examples

      iex> list_instructions()
      [%Instruction{}, ...]

  """
  def list_instructions do
    Repo.all(Instruction)
  end

  @doc """
  Gets a single instruction.

  Raises `Ecto.NoResultsError` if the Instruction does not exist.

  ## Examples

      iex> get_instruction!(123)
      %Instruction{}

      iex> get_instruction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_instruction!(id), do: Repo.get!(Instruction, id)

  @doc """
  Creates a instruction.

  ## Examples

      iex> create_instruction(%{field: value})
      {:ok, %Instruction{}}

      iex> create_instruction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_instruction(attrs \\ %{}) do
    %Instruction{}
    |> Instruction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a instruction.

  ## Examples

      iex> update_instruction(instruction, %{field: new_value})
      {:ok, %Instruction{}}

      iex> update_instruction(instruction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_instruction(%Instruction{} = instruction, attrs) do
    instruction
    |> Instruction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a instruction.

  ## Examples

      iex> delete_instruction(instruction)
      {:ok, %Instruction{}}

      iex> delete_instruction(instruction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_instruction(%Instruction{} = instruction) do
    Repo.delete(instruction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking instruction changes.

  ## Examples

      iex> change_instruction(instruction)
      %Ecto.Changeset{data: %Instruction{}}

  """
  def change_instruction(%Instruction{} = instruction, attrs \\ %{}) do
    Instruction.changeset(instruction, attrs)
  end

  alias Changelogr.Augmentations.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer)
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs) do
    answer
    |> Answer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{data: %Answer{}}

  """
  def change_answer(%Answer{} = answer, attrs \\ %{}) do
    Answer.changeset(answer, attrs)
  end

  def execute(commit_id, %Changelogr.Augmentations.Instruction{} = instruction) do
    c = Changelogr.Commits.get_commit!(commit_id)
    t =
      [
        instruction.prompt,
        c.title,
        c.body
      ]
      |> Enum.join(" ")

    format =
      if instruction do
        "json"
      else
        nil
      end

    api = Ollamex.API.new("http://turbo:11434/api")
    p = %Ollamex.PromptRequest{
      model: instruction.model,
      prompt: t,
      format: format
    }
    |> IO.inspect()

    results = Ollamex.generate_with_timeout(p, api)


    case results do
      {:ok, r} ->
        %Changelogr.Augmentations.Answer{
          model: r.model,
          response: r.response,
          status: "done",
          commit_id: commit_id,
        }
        |> Changelogr.Augmentations.create_answer()
      {:error, reason} ->
        IO.puts reason
    end

  end

end
