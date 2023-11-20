defmodule Changelogr.Repo.Migrations.CreateChangelogs do
  use Ecto.Migration

  def change do
    create table(:changelogs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :kernel_version, :string
      add :url, :string
      add :date, :naive_datetime
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end