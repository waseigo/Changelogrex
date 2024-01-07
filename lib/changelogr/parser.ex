defmodule Changelogr.Commit do
  defstruct [
    :kernel_version,
    :title,
    :topics,
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
    :co_developed_by,
    :stable_dep_of,
    :debugged_by,
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
  # @filename "priv/static/ChangeLog*"

  @all_fields %{
    commit: "Commit",
    author: "Author",
    merge: "Merge",
    date: "Date",
    reported_by: "Reported-by",
    tested_by: "Tested-by",
    message_id: "Message-Id",
    noticed_by: "Noticed-by",
    suggested_by: "Suggested-by",
    fixes: "Fixes",
    reviewed_by: "Reviewed-by",
    co_developed_by: "Co-developed-by",
    stable_dep_of: "Stable-dep-of",
    debugged_by: "Debugged-by",
    closes: "Closes",
    cc: "Cc",
    acked_by: "Acked-by",
    signed_off_by: "Signed-off-by",
    link: "Link",
    upstream_commit: [
      ~r/\[ Upstream commit\s(?<uc>[[:alnum:]]*)\s\]\n/,
      ~r/commit\s(?<uc>[[:alnum:]]*)\supstream\.\n/
    ]
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
    regexes = @all_fields[:upstream_commit]

    %Changelogr.Commit{body: b} = commit

    scan =
      regexes
      |> Enum.map(&Regex.scan(&1, b))
      |> List.flatten()

    if Enum.empty?(scan) do
      commit
    else
      [extract, uc] = scan

      b_new = String.replace(b, extract, "")

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

  def process_body(commit) do
    body = Map.get(commit, :body)
    {:ok, regex} = Regex.compile(@indentation)

    # new with regex and without splitting into paragraphs because it was breaking kernel dmesg etc.
    [title, b_new] =
      Regex.replace(regex, body, "")
      |> String.trim()
      |> String.split("\n", parts: 2)
      |> Enum.map(&String.trim/1)
      |> Kernel.++([""])
      |> Enum.slice(0..1)

    # body
    # |> String.replace(@indentation, "")
    # |> String.split("\n")
    # |> Enum.map(fn x ->
    #   case x do
    #     "" -> "\n"
    #     _ -> x <> " "
    #   end
    # end)
    # |> List.to_string()
    # |> String.trim()
    # |> String.split("\n")
    # |> Enum.map(&String.trim(&1))

    commit
    |> Map.put(:body, b_new)
    |> Map.merge(extract_topics(title))
  end

  def extract_topics(title) when is_bitstring(title) do
    regex = ~r/([[:graph:]]*)\:[[:space:]]/
    topics = Regex.scan(regex, title)
    keys = [:primary, :secondary, :tertiary]

    case topics do
      [] ->
        %{
          :title => title,
          :topics =>
            [keys, [nil, nil, nil]]
            |> List.zip()
            |> Map.new()
        }

      _ ->
        title =
          Regex.split(regex, title)
          |> List.last()

        topics =
          topics
          |> Enum.map(fn x -> List.last(x) end)
          |> Stream.concat(Stream.repeatedly(fn -> nil end))
          |> Enum.take(length(keys))
          |> (&List.zip([keys, &1])).()
          |> Map.new()

        %{title: title, topics: topics}
    end
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
