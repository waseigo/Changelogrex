defmodule Changelogr.Kernels.Changelog do
  use Ecto.Schema
  import Ecto.Changeset

  alias Changelogr.Commits.Commit

  @derive {
    Flop.Schema,
    filterable: [:date, :processed], sortable: [:date, :processed]
  }

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string
  schema "changelogs" do
    # field :id, :string
    field :date, :naive_datetime
    # field :kernel_version, :string
    field :timestamp, :utc_datetime
    field :url, :string
    field :processed, :boolean, default: false
    has_many :commits, Commit

    timestamps()
  end

  @doc false
  def changeset(changelog, attrs) do
    changelog
    |> cast(attrs, [:id, :url, :date, :timestamp])
    # |> validate_required([:id, :url, :date, :timestamp])
    |> validate_required([:id])
    |> validate_format(:id, ~r/^(0|[1-9]\d*)\.(\d{1,2})(?:\.(\d{1,3}))?$/)
    |> unique_constraint(:id)
  end
end
