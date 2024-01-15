defmodule Changelogr.Augmentations.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Augmentations.Instruction
  alias Changelogr.Commits.Commit

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "answers" do
    field :model, :string
    field :response, :string
    field :status, :string
    # field :commit_id, :id
    # field :instruction_id, :id
    belongs_to :instruction, Instruction, type: :binary_id
    belongs_to :commit, Commit, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:response, :model, :status])
    |> validate_required([:response, :model, :status])
  end
end
