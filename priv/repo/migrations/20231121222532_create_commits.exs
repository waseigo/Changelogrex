defmodule Changelogr.Repo.Migrations.CreateCommits do
  use Ecto.Migration

  def change do
    create table(:commits, primary_key: false) do
      add :id, :string, primary_key: true
      #      add :commit, :string
      add :title, :string
      add :body, :text
      add :changelog_id, references(:changelogs, type: :string, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:commits, :id)
  end
end
