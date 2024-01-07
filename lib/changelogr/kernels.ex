defmodule Changelogr.Kernels do
  @moduledoc """
  The Kernels context.
  """

  import Ecto.Query, warn: false
  alias Changelogr.Repo

  alias Changelogr.Kernels.Changelog

  @doc """
  Returns the list of changelogs.

  ## Examples

      iex> list_changelogs()
      [%Changelog{}, ...]

  """
  def list_changelogs do
    Repo.all(Changelog)
  end

  @doc """
  Returns the list of changelogs filtered with Flop using the provided params
  """
  def list_changelogs(params) do
    Flop.validate_and_run(Changelog, params, for: Changelog)
  end

  @doc """
  Gets a single changelog.

  Raises `Ecto.NoResultsError` if the Changelog does not exist.

  ## Examples

      iex> get_changelog!(123)
      %Changelog{}

      iex> get_changelog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_changelog!(id), do: Repo.get!(Changelog, id)

  @doc """
  Creates a changelog.

  ## Examples

      iex> create_changelog(%{field: value})
      {:ok, %Changelog{}}

      iex> create_changelog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_changelog(attrs \\ %{}) do
    %Changelog{}
    |> Changelog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a changelog.

  ## Examples

      iex> update_changelog(changelog, %{field: new_value})
      {:ok, %Changelog{}}

      iex> update_changelog(changelog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_changelog(%Changelog{} = changelog, attrs) do
    changelog
    |> Changelog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a changelog.

  ## Examples

      iex> delete_changelog(changelog)
      {:ok, %Changelog{}}

      iex> delete_changelog(changelog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_changelog(%Changelog{} = changelog) do
    Repo.delete(changelog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking changelog changes.

  ## Examples

      iex> change_changelog(changelog)
      %Ecto.Changeset{data: %Changelog{}}

  """
  def change_changelog(%Changelog{} = changelog, attrs \\ %{}) do
    Changelog.changeset(changelog, attrs)
  end
end
