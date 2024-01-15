defmodule Changelogr.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :response, :text
      add :model, :string
      add :status, :string
      #add :commit_id, references(:commits, on_delete: :nothing), type: :string
      #add :instruction_id, references(:instructions, on_delete: :nothing), type: :binary_id

      timestamps(type: :utc_datetime)
    end

    #create index(:answers, [:commit_id])
    #create index(:answers, [:instruction_id])
  end
end
