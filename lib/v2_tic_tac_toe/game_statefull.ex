defmodule V2TicTacToe.GameStatefull do
  @moduledoc """
  This module defines a GenServer responsible for managing the game state of a Tic-Tac-Toe game.

  It allows for starting, updating, and restarting games, as well as broadcasting events and handling game logic.

  Please refer to individual function documentation for more details on their usage.
  """
  use GenServer

  @doc """
  Starts a GenServer process with the provided initial state.

  ## Params

  - `initial_state`: The initial state of the GenServer.

  """
  @spec start_link(map()) :: {:ok, pid()} | {:error, any()}
  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: String.to_atom(initial_state.id))
  end

  @doc """
  Retrieves the game state associated with the given `code`.

  ## Params

  - `code`: The code associated with the game.

  """
  @spec get(atom() | binary()) :: map()
  def get(code) when is_binary(code), do: String.to_atom(code) |> get()

  def get(code) do
    GenServer.call(code, :get)
  end

  @doc """
  Updates the game state associated with the given `code` by making a move at the specified `position`.

  ## Params

  - `code`: The code associated with the game.
  - `position`: The position where the move is made.

  """
  @spec update(atom() | binary(), integer) :: map()
  def update(code, position) when is_binary(code), do: String.to_atom(code) |> update(position)

  def update(code, position) do
    GenServer.call(code, {:update, position})
  end

  @doc """
  Restarts the game associated with the given `code`.

  ## Params

  - `code`: The code associated with the game.

  """
  @spec restart(atom() | binary()) :: map()
  def restart(code) when is_binary(code), do: String.to_atom(code) |> restart()

  def restart(code) do
    GenServer.call(code, :restart)
  end

  @doc """
  Stops the GenServer associated with the given `code`.

  ## Params

  - `code`: The code associated with the game.

  """
  @spec stop(atom() | binary()) :: :ok
  def stop(code) when is_binary(code), do: String.to_atom(code) |> stop()

  def stop(code) do
    GenServer.stop(code, :normal)
  end

  @doc """
  Broadcasts an event to the specified `code` using Phoenix.PubSub.

  ## Params

  - `code`: The code associated with the game.
  - `event`: The event to be broadcast.

  """
  @spec broadcast(binary(), any()) :: :ok
  def broadcast(code, event) do
    Phoenix.PubSub.broadcast(V2TicTacToe.PubSub, code, event)
    :ok
  end

  @doc """
  Subscribes to events related to the specified `code` using Phoenix.PubSub.

  ## Params

  - `code`: The code associated with the game.

  """
  @spec subscribe(binary()) :: :ok | {:error, {:already_registered, pid()}}
  def subscribe(code) do
    Phoenix.PubSub.subscribe(V2TicTacToe.PubSub, code)
  end

  @doc false
  @spec init(map()) :: {:ok, any()}
  def init(initial_state) do
    {:ok, initial_state}
  end

  @doc false
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def handle_call({:update, position}, _from, state) do
    state = move(state, position)
    broadcast(state.id, {:update, state})
    {:reply, state, state}
  end

  @doc false
  def handle_call(:restart, _from, state) do
    state = Map.put(state, :game, new_game())
    broadcast(state.id, {:update, state})
    {:reply, state, state}
  end

  @spec new_game() :: TicTacToe.Game.t()
  @doc false
  def new_game do
    game = TicTacToe.new_game()
    (game.current_player == :player1 && game) || new_game()
  end

  @doc false
  defp move(state = %{game: %{current_player: :computer}}, _position) do
    Map.put(state, :game, TicTacToe.computer_move(state.game)) |> won_moves()
  end

  @doc false
  defp move(state = %{game: %{current_player: :player1}}, position) do
    state = Map.put(state, :game, TicTacToe.player_move(state.game, position)) |> won_moves()
    (state.vs == to_string(:computer) && move(state, nil)) || state
  end

  @doc false
  defp won_moves(state = %{game: %{winner: winner}}) do
    if winner == :computer || winner == :player1 do
      winner_positions =
        List.flatten(state.game.board)
        |> Enum.with_index()
        |> Enum.reduce([], fn {x, index}, list ->
          (x == winner && [index + 1 | list]) || list
        end)
        |> has_matching_sublist()

      Map.put(state, :winning_position, winner_positions)
    else
      state
    end
  end

  @doc false
  defp winning_possibilities do
    [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 5, 9],
      [3, 5, 7]
    ]
  end

  @doc false
  defp has_matching_sublist(result) do
    Enum.find(winning_possibilities(), fn [x, y, z] ->
      Enum.member?(result, x) && Enum.member?(result, y) && Enum.member?(result, z)
    end)
  end
end
