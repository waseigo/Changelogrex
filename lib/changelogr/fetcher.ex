defmodule Changelogr.Fetcher do
  @kernel_org_url "https://cdn.kernel.org/pub/linux/kernel/"
  @changelog_filename_prefix "ChangeLog-"

  def fetch_html(major) do
    base_url = baseurl(major)

    response =
      base_url
      |> URI.to_string()
      |> (&Finch.build(:get, &1)).()
      |> Finch.request(Changelogr.Finch)

    case response do
      {:error, http_response} ->
        {:error, http_response}

      {:ok, http_response} ->
        baseurl_header = {"base-url", base_url}

        {:ok,
         http_response
         |> Map.update!(:headers, &[baseurl_header | &1])}
    end
  end

  def extract_changelog_urls({:ok, %Finch.Response{body: body, headers: headers}}) do
    base_url =
      headers
      |> Map.new()
      |> Map.get("base-url")
      |> URI.parse()

    body
    |> Floki.parse_document!()
    |> Floki.find("a")
    |> Stream.map(&ahref_to_uri(&1, base_url))
    |> Stream.filter(&String.match?(elem(&1, 1), ~r/#{@changelog_filename_prefix}*/))
    |> Enum.to_list()
    |> Map.new()
  end

  def extract_dates({:ok, %Finch.Response{body: body, headers: headers}}) do
    scan = Regex.scan(~r/>([^<]*)/m, body)

    start_index =
      scan
      |> Enum.find_index(&(&1 == [">../", "../"]))

    scan
    |> Enum.slice((start_index + 2)..-1)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&List.delete_at(&1, 0))
    |> Enum.map(&List.delete_at(&1, 1))
    |> Enum.reject(&(&1 == ["\r\n", "\r\n"] or &1 == ["", ""]))
    |> Enum.map(fn [a, b] ->
      [a, Regex.run(~r/\d{2}-\D{3}-\d{4} \d{2}:\d{2}/, b)] |> List.flatten()
    end)
    |> Enum.filter(&String.match?(List.first(&1), ~r/#{@changelog_filename_prefix}*/))
    |> Enum.map(fn [a, b] ->
      {href_to_version(a), Timex.parse!(b, "%e-%b-%Y %H:%M", :strftime)}
    end)
    |> Map.new()
  end

  defp href_to_version(href) do
    Regex.replace(
      ~r/#{@changelog_filename_prefix}/,
      href,
      ""
    )
  end

  defp ahref_to_uri(ahref, baseurl) do
    href =
      ahref
      |> Floki.attribute("a", "href")
      |> hd()

    version = href_to_version(href)

    uri =
      href
      |> (&URI.merge(baseurl, &1)).()
      |> URI.to_string()

    {version, uri}
  end

  defp baseurl(major) do
    @kernel_org_url
    |> URI.parse()
    |> URI.merge(major <> "/")
  end
end
