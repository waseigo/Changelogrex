defmodule Changelogr.Augmentations.Instruction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Augmentations.Answer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "instructions" do
    field :json, :boolean, default: false
    field :model, :string
    field :prompt, :string
    field :friendly, :string
    # has_many :answers, Answer #, foreign_key: :id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(instruction, attrs) do
    instruction
    |> cast(attrs, [:friendly, :prompt, :model, :json])
    |> validate_required([:friendly, :prompt, :model, :json])
  end
end
