defmodule Changelogr.Commits.Commit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Kernels.Changelog

  @derive {
    Flop.Schema,
    filterable: [:changelog_id, :title, :body], sortable: [:changelog_id, :title]
  }

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string
  schema "commits" do
    # field :id, :string
    field :body, :string
    field :title, :string
    # field :commit, :string
    belongs_to :changelog, Changelog

    timestamps()
  end

  @doc false
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:id, :title, :body])
    |> validate_required([:id, :title, :body])
  end
end
