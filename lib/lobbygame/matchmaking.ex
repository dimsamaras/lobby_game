defmodule Lobbygame.MatchMaking do
  use GenServer

  alias Lobbygame.Lobby
  @default_lobby_id 723
  # client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_user_to_lobby(_lobby_id, user_id) do
    GenServer.call(__MODULE__, {:add_user_to_lobby, @default_lobby_id, user_id})
  end

  def remove_user_from_lobby(_lobby_id, user_id) do
    GenServer.call(__MODULE__, {:remove_user_from_lobby, @default_lobby_id, user_id})
  end

  def reset() do
    GenServer.cast(__MODULE__, {:reset_lobby})
  end

  # server
  @impl true
  def init(server) do
    {:ok, server}
  end

  @impl true
  def handle_call({:add_user_to_lobby, lobby_id, user_id}, _from, server) do
    server =
      unless Map.has_key?(server, lobby_id) do
        create_lobby(lobby_id, server)
      else
        server
      end

    if length(server[lobby_id]) < 4 do
      server =
        if length(server[lobby_id]) < 1 do
          %{lobby_id => [user_id]}
        else
          Map.put(server, lobby_id, server[lobby_id] ++ [user_id])
        end

      Lobby.add_user(user_id)
    end

    {:reply, server, server}
  end

  @impl true
  def handle_call({:remove_user_from_lobby, lobby_id, user_id}, _from, server) do
    server = Map.put(server, lobby_id, List.delete(server[lobby_id], user_id))
    Lobby.remove_user(user_id)
    {:reply, server, server}
  end

  @impl true
  def handle_cast({:reset_lobby}, server) do
    {:noreply, server}
  end

  defp create_lobby(lobby_id, server) do
    Map.put(server, lobby_id, [])
  end
end
