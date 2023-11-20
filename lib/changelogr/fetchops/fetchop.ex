defmodule Changelogr.Fetchops.Fetchop do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fetchops" do
    field :errors, :string
    field :status, :integer
    field :timestamp, :utc_datetime
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(fetchop, attrs) do
    fetchop
    |> cast(attrs, [:url, :timestamp, :status, :errors])
    |> validate_required([:url, :timestamp, :status, :errors])
  end
end
