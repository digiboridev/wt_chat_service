defmodule WTChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # unless Mix.env == :prod do
    #   Dotenv.load
    #   Mix.Task.run("loadconfig")
    # end

    children = [
      WTChatWeb.Telemetry,
      WTChat.Repo,
      {DNSCluster, query: Application.get_env(:wt_chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WTChat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WTChat.Finch},
      # Start a worker by calling: WTChat.Worker.start_link(arg)
      # {WTChat.Worker, arg},
      # Start to serve requests, typically the last entry
      WTChatWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WTChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WTChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
