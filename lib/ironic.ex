defmodule Ironic do
  use GenServer

  require Logger

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: :freenode)

  def join(network, channel), do: GenServer.call(network, {:join, channel})

  def init(_) do
    {:ok, client} = ExIrc.start_link!()

    ExIrc.Client.add_handler(client, self())
    ExIrc.Client.connect!(client, "irc.freenode.net", 6667)
    ExIrc.Client.logon(client, "16marca", name(), "hauleth", "Bot")

    {:ok, client}
  end

  def handle_call({:join, channel}, _ref, client) do
    result = ExIrc.Client.join(client, channel)

    {:reply, result, client}
  end

  def handle_info({:names_list, _, _}, client), do: {:noreply, client}

  def handle_info({:mentioned, "hauleth_: help" <> _, _, channel} , client) do
    ExIrc.Client.msg(client, :privmsg, channel, "Hi I am Ironic bot")
    ExIrc.Client.msg(client, :privmsg, channel, " ")

    ExIrc.Client.msg(client, :privmsg, channel, "I am connected to:")
    for channel <- ExIrc.Client.channels(client) do
      ExIrc.Client.msg(client, :privmsg, channel, "    " <> channel)
    end

    {:noreply, client}
  end

  def handle_info({:received, msg, %ExIrc.SenderInfo{nick: nick}, channel}, client) do
    IO.puts IO.ANSI.format([:green, channel, " ", :red, ?<, nick, ?>, :reset, " ", msg])

    {:noreply, client}
  end

  def handle_info(msg, client) do
    Logger.info inspect msg

    {:noreply, client}
  end

  defp name, do: Application.get_env(:ironic, :nick, "ironic")
end
