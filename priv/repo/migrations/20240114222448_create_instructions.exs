defmodule Changelogr.Repo.Migrations.CreateInstructions do
  use Ecto.Migration

  def change do
    create table(:instructions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :prompt, :text
      add :model, :string
      add :json, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
