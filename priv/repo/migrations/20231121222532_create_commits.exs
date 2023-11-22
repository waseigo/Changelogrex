defmodule Changelogr.Repo.Migrations.CreateCommits do
  use Ecto.Migration

  def change do
    create table(:commits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :commit, :string
      add :title, :string
      add :body, :text
      add :changelog_id, references(:changelogs, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:commits, :commit)
  end
end
