defmodule Changelogr.Commit do
  defstruct [
    :kernel_version,
    :changelog_url,
    :fetched_timestamp,
    :changelog_timestamp,
    :commit,
    :author,
    :date,
    :body,
    :reported_by,
    :tested_by,
    :message_id,
    :noticed_by,
    :suggested_by,
    :fixes,
    :reviewed_by,
    :closes,
    :cc,
    :acked_by,
    :signed_off_by,
    :link,
    :upstream_commit
  ]
end

defmodule Changelogr.Parser do
  alias Changelogr.ChangeLog
  alias Changelogr.Commit
  alias Changelogr.Fetcher
  # @filename "priv/static/ChangeLog*"

  @all_fields %{
    commit: "Commit",
    author: "Author",
    date: "Date",
    reported_by: "Reported-by",
    tested_by: "Tested-by",
    message_id: "Message-Id",
    noticed_by: "Noticed-by",
    suggested_by: "Suggested-by",
    fixes: "Fixes",
    reviewed_by: "Reviewed-by",
    closes: "Closes",
    cc: "Cc",
    acked_by: "Acked-by",
    signed_off_by: "Signed-off-by",
    link: "Link",
    upstream_commit: "[ Upstream commit "
  }

  @single_fields ["Author", "Date"]
  @indentation "    "
  @kernel_version_regex ~r/^(0|[1-9]\d*)\.(\d{1,2})(?:\.(\d{1,3}))?$/
  @kernel_version_regex_named ~r/^(?<major>0|[1-9]\d*)\.(?<minor>\d{1,2})(?:\.(?<patch>\d{1,3}))?$/

  def changelog_to_commits(
        %Changelogr.ChangeLog{
          body: body
        } = changelog
      ) do
    body
    |> then(
      &Regex.split(~r/^commit .*\n/m, &1,
        trim: true,
        include_captures: true
      )
    )
    # group commit xxx and body in one list
    |> Enum.chunk_every(2)
    |> Enum.map(&initialize_commit_struct(&1, changelog))
  end

  def initialize_commit_struct(commit_list_item, %ChangeLog{
        kernel_version: kver,
        url: cl_url,
        date: cl_ts,
        timestamp: fetch_ts
      }) do
    new_commit =
      List.zip([
        [:commit, :body],
        commit_list_item
      ])
      |> Map.new()
      |> then(
        &Map.merge(
          %Commit{},
          &1
        )
      )

    %{
      new_commit
      | :kernel_version => kver,
        :changelog_url => cl_url,
        :changelog_timestamp => cl_ts,
        :fetched_timestamp => fetch_ts
    }
  end

  def extract_field(commit, :commit) do
    %Changelogr.Commit{commit: c} = commit

    c_new =
      c
      |> String.replace("commit ", "")
      |> String.trim()

    commit
    |> Map.put(:commit, c_new)
  end

  def extract_field(commit, :upstream_commit) do
    field = @all_fields[:upstream_commit]

    %Changelogr.Commit{body: b} = commit

    {:ok, regex} =
      Regex.compile("[[:blank:]]*?" <> Regex.escape(field) <> "[[:alnum:]]*\s\]\\n\s*")

    extract =
      Regex.scan(regex, b)
      |> List.flatten()

    if Enum.empty?(extract) do
      commit
    else
      extract = hd(extract)
      b_new = String.replace(b, extract, "")
      {:ok, regex} = Regex.compile(Regex.escape(field) <> "(?<uc>[[:alnum:]]*)\s\]")

      uc =
        Regex.named_captures(regex, extract)
        |> Map.get("uc")

      commit
      |> Map.put(:body, b_new)
      |> Map.put(:upstream_commit, uc)
    end
  end

  def extract_field(commit, key) do
    field = @all_fields[key]
    {:ok, regex} = Regex.compile("[[:blank:]]*?" <> Regex.escape(field) <> ":\s.*\n")

    %Changelogr.Commit{body: body} = commit

    extract =
      body
      |> then(
        &Regex.scan(regex, &1,
          trim: true,
          include_captures: true
        )
      )
      |> List.flatten()

    if is_nil(Map.get(commit, key)) do
      Enum.reduce(
        extract,
        commit,
        fn k, acc ->
          b = Map.get(acc, :body)
          b_new = String.replace(b, k, "")
          Map.put(acc, :body, b_new)
        end
      )
      |> Map.put(key, clean_list(extract, field))
    else
      commit
    end
  end

  defp clean_list(list, field) do
    list
    |> Enum.map(&String.replace(&1, field <> ":", ""))
    |> Enum.map(&String.trim(&1))
    |> process_empty_list()
    |> process_single_field(field)
  end

  defp process_single_field(list, field) when is_list(list) and field == "Date" do
    hd(list)
    |> Timex.parse!("%a %b %-d %H:%M:%S %Y %z", :strftime)
  end

  defp process_single_field(list, field) when is_list(list) do
    if field in @single_fields do
      hd(list)
    else
      list
    end
  end

  defp process_single_field(list, _field) when is_nil(list) do
    nil
  end

  # FIXME documentation on unwrap and unindent of :body
  def process_body(commit) do
    body = Map.get(commit, :body)

    b_new =
      body
      |> String.replace(@indentation, "")
      |> String.split("\n")
      |> Enum.map(fn x ->
        case x do
          "" -> "\n"
          _ -> x <> " "
        end
      end)
      |> List.to_string()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))

    commit
    |> Map.put(:body, b_new)
  end

  def process_empty_list(list) do
    if Enum.empty?(list) do
      nil
    else
      list
    end
  end

  def extract_all_fields(%Commit{} = commit) do
    @all_fields
    |> Map.keys()
    |> Enum.reduce(
      commit,
      fn k, acc ->
        extract_field(
          acc,
          k
        )
      end
    )
    |> process_body()
  end

  def validate_and_parse_kernel_version(v) when is_bitstring(v) do
    case Regex.match?(@kernel_version_regex, v) do
      false ->
        {:error, "Could not validate kernel version"}

      true ->
        {:ok, parse_kernel_version!(v)}
    end
  end

  def parse_kernel_version!(v) when is_bitstring(v) do
    Regex.named_captures(@kernel_version_regex_named, v)
    |> Map.new(fn {k, v} ->
      {
        String.to_atom(k),
        case v do
          "" -> nil
          _ -> String.to_integer(v)
        end
      }
    end)
  end

  def format_version_string(%{major: major, minor: minor, patch: patch}) do
    "#{major}.#{minor}" <>
      if patch != nil, do: ".#{patch}", else: ""
  end
end
