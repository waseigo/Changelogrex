# Changelogr

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Loading all ChangeLog data and processing it in parallel

```elixir
Path.wildcard("/home/tisaak/changelog/*/*") |> Enum.map(fn x -> Changelogr.Parser.to_commits(x) |> Task.async_stream(&Changelogr.Parser.extract_all_fields(&1)) |> Enum.to_list() end)
```