defmodule Changelogr.Kernels.Changelog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "changelogs" do
    field :date, :naive_datetime
    field :kernel_version, :string
    field :timestamp, :utc_datetime
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(changelog, attrs) do
    changelog
    |> cast(attrs, [:kernel_version, :url, :date, :timestamp])
    |> validate_required([:kernel_version, :url, :date, :timestamp])
  end
end