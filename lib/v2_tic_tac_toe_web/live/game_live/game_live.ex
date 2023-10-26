defmodule V2TicTacToeWeb.GameLive do
  @moduledoc """
  The `V2TicTacToeWeb.GameLive` module defines a Phoenix LiveView responsible for managing a Tic-Tac-Toe game session.

  It handles mounting the game, updating the game state, restarting the game, and starting a new game.

  """
  use V2TicTacToeWeb, :live_view

  alias V2TicTacToe.GameStatefull

  @impl true
  @spec mount(map(), any(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  @doc """
  Mounts the game LiveView with the specified game parameters.

  When a game is mounted, the game state is initialized, and the game LiveView becomes active.

  ## Params

  - `%{"code" => code, "vs" => vs}`: A map containing the game code and the opponent.
  - `_session`: The session data.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:ok, socket}` indicating a successful mount.

  """
  def mount(%{"code" => code, "vs" => vs}, _session, socket) do
    if connected?(socket), do: GameStatefull.subscribe(code)
    initial_state = %{id: code, vs: vs, game: GameStatefull.new_game(), winning_position: []}
    GameStatefull.start_link(initial_state)

    {:ok, assign(socket, :game, initial_state)}
  end

  @impl true
  @spec handle_event(String.t(), %{String.t() => String.t()}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  @doc """
  Handles the "update" event to make a move in the game.

  When the "update" event is triggered, the specified move is made in the game by updating the game state.

  ## Params

  - `event`: The event name, which should be "update."
  - `%{"col" => col}`: A map containing the column position of the move.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:noreply, socket}` indicating that the event was handled successfully.

  """
  def handle_event("update", %{"col" => col}, socket) do
    position = String.to_integer(col) + 1
    GameStatefull.update(socket.assigns.game.id, position)
    {:noreply, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  @doc """
  Handles the "restart" event to restart the game.

  When the "restart" event is triggered, the game is restarted, and the game state is reset.

  ## Params

  - `event`: The event name, which should be "restart."
  - `_unsigned_params`: Unused parameters.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:noreply, socket}` indicating that the event was handled successfully.

  """
  def handle_event("restart", _unsigned_params, socket) do
    GameStatefull.restart(socket.assigns.game.id)
    {:noreply, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  @doc """
  Handles the "newgame" event to start a new game.

  When the "newgame" event is triggered, the current game is stopped, and the user is redirected to the main dashboard for starting a new game.

  ## Params

  - `event`: The event name, which should be "newgame."
  - `_unsigned_params`: Unused parameters.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:noreply, socket}` indicating that the event was handled successfully.

  """
  def handle_event("newgame", _unsigned_params, socket) do
    GameStatefull.stop(socket.assigns.game.id)
    {:noreply, redirect(socket, to: "/")}
  end

  @impl true
  @spec handle_info({:update, any()}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  @doc """
  Handles incoming update information and updates the game state in the socket.

  When information about game state changes is received, this function updates the game state in the LiveView socket.

  ## Params

  - `{:update, state}`: A tuple indicating an update event and the new game state.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:noreply, socket}` indicating that the information was successfully processed.

  """
  def handle_info({:update, state}, socket) do
    {:noreply, update(socket, :game, fn _game -> state end)}
  end
end
