defmodule LobbygameWeb.LobbyChannel do
  use Phoenix.Channel

  alias Lobbygame.MatchMaking
  alias Lobbygame.Lobby

  @default_lobby_id 723
  @doc """
  Join any channel, and return the socket to the client
  """
  def join("lobby:game", _params, socket) do
    IO.inspect("User #{socket.assigns.user_id} listening on main game lobby")
    {:ok, %{lobby_id: @default_lobby_id}, socket}
  end

  def join("lobby:" <> lobby, _params, socket) do
    IO.inspect("User #{socket.assigns.user_id} listening on lobby #{lobby}")
    MatchMaking.add_user_to_lobby(lobby, socket.assigns.user_id)
    {:ok, %{lobby_id: @default_lobby_id, user_id: socket.assigns.user_id}, socket}
  end

  def handle_in("change_color", _params, socket) do
    Lobby.change_color(socket.assigns.user_id)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.topic do
      "lobby:" <> lobby ->
        MatchMaking.remove_user_from_lobby(lobby, socket.assigns.user_id)
        IO.inspect("Remove user #{socket.assigns.user_id} from lobby #{lobby}")

      topic ->
        IO.inspect("Wrong topic #{inspect(topic)} for channel #{__MODULE__}")
    end
  end
end
