defmodule Changelogr.Commits.Commit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Kernels.Changelog

  @derive {
    Flop.Schema,
    filterable: [:changelog_id],
    sortable: [:changelog_id]
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "commits" do
    field :body, :string
    field :title, :string
    field :commit, :string
    belongs_to :changelog, Changelog

    timestamps()
  end

  @doc false
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:commit, :title, :body])
    |> validate_required([:commit, :title, :body])
  end
end
