defmodule Changelogr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChangelogrWeb.Telemetry,
      # Start the Ecto repository
      Changelogr.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Changelogr.PubSub},
      # Start Finch
      {Finch, name: Changelogr.Finch},
      # Start the Endpoint (http/https)
      ChangelogrWeb.Endpoint
      # Start a worker by calling: Changelogr.Worker.start_link(arg)
      # {Changelogr.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Changelogr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChangelogrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
