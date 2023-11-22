# Changelogrex

🐧🌾🗒️🫅 (Linux kernel changelog rex)

Fetches and parses Linux kernel ChangeLogs from [https://kernel.org/pub/linux/kernel/](https://kernel.org/pub/linux/kernel/) into Elixir structs that can later be handled with Ecto.

## Front-end stuff

[![demo](https://asciinema.org/a/113463.png)](https://files.waseigo.com/api/public/dl/IHwECYBc?inline=true)




## Back-end stuff

### Batch fetch-and-process Linux kernel v6.x ChangeLogs into properly parsed commits

First, check which ChangeLogs are available.

```elixir
{ :ok, available } = Changelogr.Fetcher.fetch_available("v6.x")
```

`available` is a %FetchOp{} (*Fetch* *Op*eration) struct that contains HREFs and dates of all ChangeLogs from the directory listing of [https://kernel.org/pub/linux/kernel/v6.x/](https://kernel.org/pub/linux/kernel/v6.x/).

```elixir
iex> IO.inspect available
%Changelogr.FetchOp{
  url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/",
  timestamp: ~U[2023-11-19 10:43:10Z],
  status: 200,
  body: "<html>\r\n<head><title>Index of /pub/linux/kernel/v6.x/</title></head> ...",
  hrefs: %{
    "6.3.3" => "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.3.3",
    "6.5.6" => "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.5.6",
    ...
  },
  dates: %{
    "6.3.3" => ~N[2023-05-17 12:09:00],
    "6.5.6" => ~N[2023-10-06 11:24:00],
    ...
  },
  errors: nil
}
```

To be able to fetch their content, we convert `available` into a list of `%ChangeLog{}` structs.

```elixir
{ :ok, fetchable } = Changelogr.Fetcher.fetchop_to_changelogs(available)
```

`fetchable` is a list of `{ status, %ChangeLog{} }` tuples. The `:body` attribute of the struct is still `nil`.

```elixir
iex> IO.inspect fetchable
[
  %Changelogr.ChangeLog{
    kernel_version: "6.1.35",
    url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.35",
    date: ~N[2023-06-21 14:12:00],
    timestamp: nil,
    body: nil,
    commits: nil
  },
  %Changelogr.ChangeLog{
    kernel_version: "6.1.40",
    url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.40",
    date: ~N[2023-07-23 12:00:00],
    timestamp: nil,
    body: nil,
    commits: nil
  },
...
]
```

Next, we'll fetch them in sequence.

```elixir
changelogs = Enum.map(fetchable, &Changelogr.Fetcher.fetch_changelog/1) 
```

If the fetch was successful, the `:body` of each `%ChangeLog{}` struct in the list now contains the ChangeLog text, but it is still unparsed (`:commit` is still `nil`).

For example:
```elixir
iex> hd changelogs
{:ok,
 %Changelogr.ChangeLog{
   kernel_version: "6.1.40",
   url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.40",
   date: ~N[2023-07-23 12:00:00],
   timestamp: ~U[2023-11-19 10:44:24Z],
   body: "commit 75389113731bb629fa5e971baf58e422414c8d23\nAuthor: Greg Kroah-Hartman <gregkh@linuxfoundation.org>\nDate:   Sun Jul 23 13:49:51 2023 +0200\n\n    Linux 6.1.40\n    \n    Link: https://lore.kernel.org/ ...",
   commits: nil
 }}
```

Next, we'll process each one of these `%ChangeLog{}` structs into `%Commit{}` structs.
1. First, we filter the list to keep only those with status `:ok`.
2. Then, we convert it into a list of `%ChangeLog{}` structs by discarding the status.
3. Finally, we parse the `:body` of each `%ChangeLog{}` structs into a list of `%Commit{}` structs in parallel.
4. Then, we select only those with status `:ok`, ...
5. ...and we flatten the list.

```elixir
commits = 
  changelogs
  |> Enum.filter(fn {status, _} -> status == :ok end)
  |> Enum.map(fn {_, x} -> x end)
  |> Task.async_stream(&Changelogr.Parser.changelog_to_commits/1)
  |> Enum.to_list()
  |> Enum.filter(fn {status, _} -> status == :ok end)
  |> Enum.map(fn {_, x} -> x end)
  |> List.flatten()
```

Each item of the `commits` list is a `%Commit{}` struct in which `:body` and `:commit` are filled in, as well as anything else known from the ChangeLog that contains the commit, and timestamps of when it was fetched, and where it was fetched from.

```elixir
iex> hd commits
%Changelogr.Commit{
  kernel_version: "6.1.35",
  changelog_url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.35",
  fetched_timestamp: ~U[2023-11-19 11:23:01Z],
  changelog_timestamp: ~N[2023-06-21 14:12:00],
  commit: "commit e84a4e368abe42cf359fe237f0238820859d5044\n",
  author: nil,
  date: nil,
  body: "Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>\nDate:   Wed Jun 21 16:01:03 2023 +0200\n\n    ...",
  reported_by: nil,
  tested_by: nil,
  message_id: nil,
  noticed_by: nil,
  suggested_by: nil,
  fixes: nil,
  reviewed_by: nil,
  closes: nil,
  cc: nil,
  acked_by: nil,
  signed_off_by: nil,
  link: nil,
  upstream_commit: nil
}
```

To fill in the rest of the attributes and to process the existing fields, we need to extract and process them. Processing is done in parallel.

```elixir
processed = 
 commits
 |> Task.async_stream(&Changelogr.Parser.extract_all_fields/1)
 |> Enum.to_list()
 |> Enum.map(fn {:ok, x} -> x end)
```

And so we end up with a list of parsed and processed commits. Here's what such a "finished" commit looks like:

```elixir
iex> hd processed
%Changelogr.Commit{
  kernel_version: "6.1.35",
  changelog_url: "https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.35",
  fetched_timestamp: ~U[2023-11-19 11:23:01Z],
  changelog_timestamp: ~N[2023-06-21 14:12:00],
  commit: "e84a4e368abe42cf359fe237f0238820859d5044",
  author: "Greg Kroah-Hartman <gregkh@linuxfoundation.org>",
  date: #DateTime<2023-06-21 16:01:03+02:00 +02 Etc/UTC+2>,
  body: ["Linux 6.1.35"],
  reported_by: nil,
  tested_by: ["Florian Fainelli <florian.fainelli@broadcom.com>",
   "Markus Reichelt <lkt+2023@mareichelt.com>",
   "Salvatore Bonaccorso <carnil@debian.org>",
   "Linux Kernel Functional Testing <lkft@linaro.org>",
   "Chris Paterson (CIP) <chris.paterson2@renesas.com>",
   "Jon Hunter <jonathanh@nvidia.com>", "Ron Economos <re@w6rz.net>",
   "Conor Dooley <conor.dooley@microchip.com>",
   "Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>",
   "Takeshi Ogasawara <takeshi.ogasawara@futuring-girl.com>",
   "Allen Pais <apais@linux.microsoft.com>",
   "Shuah Khan <skhan@linuxfoundation.org>",
   "Guenter Roeck <linux@roeck-us.net>"],
  message_id: nil,
  noticed_by: nil,
  suggested_by: nil,
  fixes: nil,
  reviewed_by: nil,
  closes: nil,
  cc: nil,
  acked_by: nil,
  signed_off_by: ["Greg Kroah-Hartman <gregkh@linuxfoundation.org>"],
  link: ["https://lore.kernel.org/r/20230619102154.568541872@linuxfoundation.org"],
  upstream_commit: nil
}
```
