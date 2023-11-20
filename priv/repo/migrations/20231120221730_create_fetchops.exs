defmodule Changelogr.Repo.Migrations.CreateFetchops do
  use Ecto.Migration

  def change do
    create table(:fetchops, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string
      add :timestamp, :utc_datetime
      add :status, :integer
      add :errors, :string

      timestamps()
    end
  end
end
