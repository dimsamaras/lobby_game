defmodule Lobbygame.Lobby do
  use GenServer

  alias User
  require Logger
  @colors [:red, :blue, :green, :yellow]
  @default_lobby_id 723
  @countdown 6
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{lobby_id: @default_lobby_id, users: []}}
  end

  # Client

  def timer_elapsed() do
    GenServer.call(__MODULE__, :timer_elapsed)
  end

  def add_user(user_id) do
    GenServer.call(__MODULE__, {:add_user, user_id})
  end

  def remove_user(user_id) do
    GenServer.call(__MODULE__, {:remove_user, user_id})
  end

  def change_color(user_id) do
    GenServer.call(__MODULE__, {:change_color, user_id})
  end

  # Server

  def handle_call({:add_user, user_id}, _from, state) do
    if length(state.users) >= 4 do
      schedule_new()
      {:reply, state, state}
    else
      users = state.users
      users = users ++ [%{user_id: user_id, points: 0, color: Enum.take_random(@colors, 1)}]
      state = Map.put(state, :users, users)

      LobbygameWeb.Endpoint.broadcast!("lobby:#{state.lobby_id}", "new_state", %{
        users: state.users
      })

      {:reply, state, state}
    end
  end

  def handle_call({:remove_user, user_id}, _from, state) do
    user =
      Enum.filter(state.users, fn user -> user.user_id == user_id end)
      |> List.first()

    users = state.users -- [user]
    state = Map.put(state, :users, users)

    LobbygameWeb.Endpoint.broadcast!("lobby:#{state.lobby_id}", "new_state", %{
      users: state.users
    })

    {:reply, state, state}
  end

  def handle_call({:change_color, user_id}, _from, state) do
    user = Enum.filter(state.users, fn user -> user.user_id == user_id end) |> List.first()
    users = state.users
    users = users -- [user]
    user = Map.put(user, :color, Enum.take_random(@colors, 1))
    users = users ++ [user]
    state = Map.put(state, :users, users)

    LobbygameWeb.Endpoint.broadcast!("lobby:#{state.lobby_id}", "new_state", %{
      users: state.users
    })

    {:reply, state, state}
  end

  def handle_info(:timer_elapsed, state) do
    losing_color = Enum.take_random(@colors, 1)

    losing_players =
      Enum.filter(state.users, fn user -> user.color == losing_color and user.points < 5 end)

    winning_players = state.users -- losing_players

    cond do
      losing_players == [] ->
        {:noreply, state}

      length(winning_players) == 2 ->
        IO.puts("DRAW!!!")
        Enum.each(winning_players, fn player -> advance_campaign(player.user_id) end)
        {:noreply, state}

      true ->
        updated_losing_players =
          Enum.map(losing_players, fn losing_player ->
            %{losing_player | points: losing_player.points + 1}
          end)

        users = state.users -- losing_players
        users = users ++ updated_losing_players
        state = Map.put(state, :users, users)

        if length(winning_players) == 1 do
          hd(winning_players).user_id
          |> advance_campaign
        end

        {:noreply, state}
    end
  end

  defp advance_campaign(user_id, amount \\ 5) do
    IO.puts("ADVANCING CAMPAIGN")
  end

  def schedule_new() do
    send(__MODULE__, :schedule_new)
  end

  def handle_info(:schedule_new, state) do
    {:ok, uuid} = Ariadne.Scheduler.notify_on_tick()

    new_state =
      state
      |> Map.put(:notif_uuid, uuid)
      |> Map.put(:timer, :os.system_time(:seconds))

    {:noreply, new_state}
  end

  def handle_info({{:scheduler, :tick}, timestamp}, state) do
    initial_timestamp = state.timer
    lapse_in_seconds = timestamp - initial_timestamp
    countdown = rem(lapse_in_seconds, @countdown)

    if countdown == 0,
      do: broadcast_color(),
      else: broadcast_tick(countdown, state)

    {:noreply, state}
  end

  defp broadcast_tick(count, state) do
    # TODO: implement broadcast tick
    countdown = @countdown - count
    Logger.info("Broadcasting tick #{countdown}")

    LobbygameWeb.Endpoint.broadcast!("lobby:#{state.lobby_id}", "timer", %{
      timer: countdown
    })
  end

  defp broadcast_color() do
    # TODO: implement broadcast color
    Logger.info("Broadcasting color!!!!")
    send(self(), :timer_elapsed)
  end
end
