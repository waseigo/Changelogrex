defmodule Changelogr.Repo.Migrations.ChangelogUniqueKernelVersion do
  use Ecto.Migration

  def change do
    create unique_index(:changelogs, :kernel_version)
  end
end
