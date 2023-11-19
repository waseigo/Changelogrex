defmodule Changelogr do
  @moduledoc """
  Changelogr keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def one(version) when is_bitstring(version) do
    r = Changelogr.Fetcher.fetch_changelog_for_version(version)
    case r do
      {:error, _} -> r
      {:ok, cl } ->
        Changelogr.Parser.changelog_to_commits(cl)
        |> Task.async_stream(&Changelogr.Parser.extract_all_fields/1)
        |> Enum.to_list()
        |> Enum.map(fn {:ok, x} -> x end)
      end
  end
end
