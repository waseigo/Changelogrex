defmodule Changelogr.FetchOp do
  defstruct [
    :url,
    :timestamp,
    :status,
    :body,
    :hrefs,
    :dates,
    # FIXME add proper error logging like in vatchex_greece
    :errors
  ]
end

defmodule Changelogr.ChangeLog do
  defstruct [
    :kernel_version,
    :url,
    # date from the directory listing
    :date,
    # when it was fetched
    :timestamp,
    :body,
    :commits
  ]
end

defmodule Changelogr.Fetcher do
  alias Changelogr.ChangeLog
  # @kernel_org_url "https://cdn.kernel.org/pub/linux/kernel/"
  @kernel_org_url "http://localhost:8000/pub/linux/kernel/"
  @changelog_filename_prefix "ChangeLog-"
  @major_version_regex ~r/^v\d{0,2}\.[\dx]$/

  def fetch_changelog_for_version(v) when is_bitstring(v) do
    r = Changelogr.Parser.validate_and_parse_kernel_version(v)

    case r do
      {:error, _} ->
        r

      {:ok, _} ->
        available =
          case kernel_version_to_subdir(v) do
            {:ok, subdir} ->
              fetch_available(subdir)

            {:error, message} ->
              {:error, message}
          end

        case available do
          {:error, message} ->
            {:error, message}

          {:ok, a} ->
            case v in Map.keys(a.hrefs) do
              false ->
                {:error, "No ChangeLog found for version #{v}"}

              true ->
                %ChangeLog{
                  kernel_version: v,
                  url: Map.get(a.hrefs, v),
                  date: Map.get(a.dates, v),
                  timestamp: a.timestamp
                }
                |> fetch_changelog()
            end
        end
    end
  end

  def fetch_changelog(changelog) do
    response = http_get(changelog.url)

    case response do
      {:error, _} ->
        {:error, %{message: "HTTP GET request error"}}

      {:ok, http_response} ->
        case http_response.status do
          200 ->
            timestamp =
              http_response.headers
              |> Map.new()
              |> Map.get("date")
              |> parse_timestamp()

            {:ok, %{changelog | body: http_response.body, timestamp: timestamp}}

          _ ->
            {:error, %{message: "HTTP status not 200", status: http_response.status}}
        end
    end
  end

  def fetchop_to_changelogs(%Changelogr.FetchOp{hrefs: hrefs, dates: dates})
      when not (is_nil(hrefs) and is_nil(dates)) do
    if Map.keys(hrefs) == Map.keys(dates) do
      changelogs =
        Map.keys(hrefs)
        |> Enum.reduce(
          [],
          fn k, acc ->
            [
              %Changelogr.ChangeLog{
                kernel_version: k,
                url: Map.get(hrefs, k),
                date: Map.get(dates, k)
              }
              | acc
            ]
          end
        )

      {:ok, changelogs}
    else
      {:error, %{message: "Unequal length of ChangeLog hrefs and dates"}}
    end
  end

  def fetch_available(major) when is_bitstring(major) do
    major
    |> fetch_html()
    |> extract_changelog_hrefs()
    |> extract_changelog_dates()
  end

  def fetch_available_all() do
    fetch_major_version_paths()
    |> Enum.map(&fetch_available(&1))
    |> Enum.filter(fn {status, _} -> status == :ok end)
    |> Enum.map(fn {:ok, data} -> Map.keys(data.hrefs) end)
    |> List.flatten()
  end

  def fetch_major_version_paths() do
    url = baseurl()

    response = http_get(url)

    case response do
      {:error, message} ->
        {:error, message}

      {:ok, http_response} ->
        http_response.body
        |> Floki.parse_document!()
        |> Floki.find("a")
        |> Enum.map(fn {_, _, c} -> hd(c) |> String.trim_trailing("/") end)
        |> Enum.filter(&String.match?(&1, @major_version_regex))
    end
  end

  def fetch_html(major) when is_bitstring(major) do
    url = baseurl(major)

    timestamp = DateTime.now!("UTC")

    default_result = %Changelogr.FetchOp{
      url: URI.to_string(url),
      timestamp: timestamp
    }

    response = http_get(default_result.url)

    case response do
      {:error, _} ->
        {:error, default_result}

      {:ok, http_response} ->
        d =
          http_response
          |> Map.get(:headers)
          |> Map.new()
          |> Map.get("date")
          |> parse_timestamp()

        {:ok,
         %{
           default_result
           | :timestamp => d,
             :status => http_response.status,
             :body => http_response.body
         }}
    end
  end

  def extract_changelog_hrefs({:ok, fetch_op}) when fetch_op.status == 200 do
    url = URI.parse(fetch_op.url)

    hrefs =
      fetch_op.body
      |> Floki.parse_document!()
      |> Floki.find("a")
      |> Stream.map(&ahref_to_uri(&1, url))
      |> Stream.filter(
        &String.match?(elem(&1, 1), ~r/#{@changelog_filename_prefix}*(?!.*\.sign)/)
      )
      |> Enum.to_list()
      |> Map.new()

    {:ok, %{fetch_op | :hrefs => hrefs}}
  end

  def extract_changelog_hrefs({:error, fetch_op}) do
    {:error, fetch_op}
  end

  def extract_changelog_dates({:ok, fetch_op}) when fetch_op.status == 200 do
    scan = Regex.scan(~r/>([^<]*)/m, fetch_op.body)

    start_index =
      scan
      |> Enum.find_index(&(&1 == [">../", "../"]))

    dates =
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
      |> Enum.filter(
        &String.match?(List.first(&1), ~r/#{@changelog_filename_prefix}*(?!.*\.sign)/)
      )
      |> Enum.map(fn [a, b] ->
        {href_to_version(a), Timex.parse!(b, "%e-%b-%Y %H:%M", :strftime)}
      end)
      |> Map.new()

    {:ok, %{fetch_op | :dates => dates}}
  end

  def extract_changelog_dates({:error, fetch_op}) do
    {:error, fetch_op}
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

  def baseurl() do
    @kernel_org_url
  end

  def baseurl(version_path) do
    @kernel_org_url
    |> URI.parse()
    |> URI.merge(version_path <> "/")
  end

  def kernel_version_to_subdir(v) when is_bitstring(v) do
    version = Changelogr.Parser.parse_kernel_version!(v)
    paths = fetch_major_version_paths()

    c1 = "v" <> Integer.to_string(version.major) <> "." <> Integer.to_string(version.minor)

    if c1 in paths do
      {:ok, c1}
    else
      c2 = "v" <> Integer.to_string(version.major) <> ".x"

      if c2 in paths do
        {:ok, c2}
      else
        {:error, "Kernel version #{v} doesn't match any path under /pub/linux/kernel/"}
      end
    end
  end

  def kernel_version_to_url(v) when is_bitstring(v) do
    cl_filename = @changelog_filename_prefix <> v

    case kernel_version_to_subdir(v) do
      {:ok, subdir} ->
        subdir
        |> baseurl()
        |> URI.merge(cl_filename)
        |> URI.to_string()

      {:error, message} ->
        {:error, message}
    end
  end

  # parse timestamp in format "Sat, 18 Nov 2023 19:39:36 GMT"
  defp parse_timestamp(t) do
    Timex.parse!(t, "%a, %d %b %Y %H:%M:%S %Z", :strftime)
  end

  def http_get(url) when is_bitstring(url) do
    r =
      Finch.build(:get, url)
      |> Finch.request(Changelogr.Finch)

    case r do
      {:ok, response} ->
        case response.status do
          200 -> r
          _ -> {:error, "HTTP status #{response.status}"}
        end

      {:error, _} ->
        r
    end
  end
end
