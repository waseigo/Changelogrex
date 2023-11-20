defmodule Changelogr.Fetchops do
  @moduledoc """
  The Fetchops context.
  """

  import Ecto.Query, warn: false
  alias Changelogr.Repo

  alias Changelogr.Fetchops.Fetchop

  @doc """
  Returns the list of fetchops.

  ## Examples

      iex> list_fetchops()
      [%Fetchop{}, ...]

  """
  def list_fetchops do
    Repo.all(Fetchop)
  end

  @doc """
  Gets a single fetchop.

  Raises `Ecto.NoResultsError` if the Fetchop does not exist.

  ## Examples

      iex> get_fetchop!(123)
      %Fetchop{}

      iex> get_fetchop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fetchop!(id), do: Repo.get!(Fetchop, id)

  @doc """
  Creates a fetchop.

  ## Examples

      iex> create_fetchop(%{field: value})
      {:ok, %Fetchop{}}

      iex> create_fetchop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fetchop(attrs \\ %{}) do
    %Fetchop{}
    |> Fetchop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fetchop.

  ## Examples

      iex> update_fetchop(fetchop, %{field: new_value})
      {:ok, %Fetchop{}}

      iex> update_fetchop(fetchop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fetchop(%Fetchop{} = fetchop, attrs) do
    fetchop
    |> Fetchop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fetchop.

  ## Examples

      iex> delete_fetchop(fetchop)
      {:ok, %Fetchop{}}

      iex> delete_fetchop(fetchop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fetchop(%Fetchop{} = fetchop) do
    Repo.delete(fetchop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fetchop changes.

  ## Examples

      iex> change_fetchop(fetchop)
      %Ecto.Changeset{data: %Fetchop{}}

  """
  def change_fetchop(%Fetchop{} = fetchop, attrs \\ %{}) do
    Fetchop.changeset(fetchop, attrs)
  end
end
