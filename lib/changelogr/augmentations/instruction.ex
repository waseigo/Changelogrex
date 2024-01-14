defmodule Changelogr.Augmentations.Instruction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "instructions" do
    field :json, :boolean, default: false
    field :model, :string
    field :prompt, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(instruction, attrs) do
    instruction
    |> cast(attrs, [:prompt, :model, :json])
    |> validate_required([:prompt, :model, :json])
  end
end
