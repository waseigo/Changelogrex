defmodule Changelogr.Repo do
  use Ecto.Repo,
    otp_app: :changelogr,
    adapter: Ecto.Adapters.SQLite3
end
