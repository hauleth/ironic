defmodule Ironic.Listener do
  use GenServer

  require Logger

  defstruct [:nick, :client, :name]

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def init(args), do: {:ok, %__MODULE__{}, {:continue, {:connect, args}}}

  def handle_continue({:connect, {args}}, state) do
    {:ok, client} = ExIrc.start_client!()

    srv_name = Keyword.fetch!(args, :name)
    host = Keyword.fetch!(args, :host)
    port = Keyword.get(args, :port, 6667)
    ssl = Keyword.get(args, :ssl, false)

    password = Keyword.get(args, :password)
    nick = Keyword.get(args, :nick, "ironic")
    user = Keyword.get(args, :user)
    name = Keyword.get(args, :name, "")

    ExIrc.Client.add_handler(client, self())

    :ok = connect(client, host, port, ssl)
    :ok = ExIrc.Client.logon(client, password, nick, user, name)

    {:noreply, struct(state, client: client, nick: nick, name: srv_name)}
  end

  defp connect(client, host, port, true), do: ExIrc.Client.connect_ssl!(client, host, port)
  defp connect(client, host, port, false), do: ExIrc.Client.connect!(client, host, port)
end
