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
      {DNSCluster, query: Application.get_env(:changelogr, :dns_cluster_query) || :ignore},
      # Start the PubSub system
      {Phoenix.PubSub, name: Changelogr.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Changelogr.Finch},
      # Start the Finch HTTP client for Ollamex to make HTTP requests to ollama's REST API
      # {Finch, name: Req.Finch},
      # Start a worker by calling: Changelogr.Worker.start_link(arg)
      # {Changelogr.Worker, arg},
      # Start to serve requests, typically the last entry
      ChangelogrWeb.Endpoint
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
