defmodule Changelogr.Commit do
  defstruct [
    :filename,
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
    :link
  ]
end

defmodule Changelogr.Parser do
  alias Changelogr.Commit
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
    link: "Link"
  }

  @single_fields ["Author", "Date"]

  def to_commits(textfile) do
    textfile
    |> to_commits_list()
    |> Enum.map(&commit_to_struct/1)
  end

  def to_commits_list(textfile) do
    textfile
    |> Path.absname()
    |> File.read!()
    |> then(
      &Regex.split(~r/^commit .*\n/m, &1,
        trim: true,
        include_captures: true
      )
    )
    |> Enum.chunk_every(2)
    |> Enum.map(
      &Kernel.++(
        [Path.basename(textfile)],
        &1
      )
    )
  end

  def commit_to_struct(commit_list_item) do
    List.zip([
      [:filename, :commit, :body],
      commit_list_item
    ])
    |> Map.new()
    |> then(
      &Map.merge(
        %Commit{},
        &1
      )
    )
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

  def extract_field(commit, key) do
    field = @all_fields[key]
    {:ok, regex} = Regex.compile("[[:blank:]]*?" <> field <> ":\s.*\n")

    %Changelogr.Commit{body: body} = commit

    extract =
      body
      |> then(
        &Regex.split(regex, &1,
          trim: true,
          include_captures: true
        )
      )

    if is_nil(Map.get(commit, key)) do
      specifics =
        extract
        |> Enum.filter(fn x -> String.contains?(x, field <> ":") end)

      new_body =
        (extract -- specifics)
        |> Enum.join()
        |> String.trim()

      commit
      |> Map.put(:body, new_body)
      |> Map.put(key, clean_list(specifics, field))
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
    # FIXME parse date
    hd(list)
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

  def process_empty_list(list) do
    if Enum.empty?(list) do
      nil
    else
      list
    end
  end

  def extract_all_fields(x) do
    @all_fields
    |> Map.keys()
    |> Enum.reduce(
      x,
      fn k, acc ->
        extract_field(
          acc,
          k
        )
      end
    )
  end
end
