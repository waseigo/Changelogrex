defmodule Changelogr.Commits.Commit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Kernels.Changelog

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "commits" do
    field :body, :string
    field :commit, :string
    belongs_to :changelog, Changelog

    timestamps()
  end

  @doc false
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:commit, :body])
    |> validate_required([:commit, :body])
  end
end
