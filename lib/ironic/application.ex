defmodule Ironic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Ironic,
      {Registry, keys: :duplicate, name: Ironic.Networks},
      {DynamicSupervisor, strategy: :one_for_one, name: Ironic.NetworksSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ironic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def networks, do: Application.get_env(:ironic, :networks)
end
