defmodule V2TicTacToeWeb.DashboardLive do
  @moduledoc """
  The `V2TicTacToeWeb.DashboardLive` module defines a Phoenix LiveView for the dashboard page. This LiveView handles events related to starting new games and generating random game codes.

  When a user clicks the "start" button, a new game is initiated with the specified opponent. The game is assigned a random code, and the user is redirected to the game page.

  This module provides functionality for managing game sessions and redirects to the appropriate game page.

  """
  use V2TicTacToeWeb, :live_view

  @spec mount(any(), any(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  @doc """
  Mounts the dashboard LiveView.

  ## Params

  - `params`: A map of parameters.
  - `session`: A map representing the session.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:ok, socket}` indicating a successful mount.

  """
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  @doc """
  Handles the "start" event to initiate a new game.

  When the "start" event is triggered with a "vs" value in the parameters, a new game is started. The game is assigned a random code and the player is redirected to the game page.

  ## Params

  - `event`: The event name, in this case, "start."
  - `params`: A map of event parameters.
  - `socket`: The LiveView socket.

  ## Returns

  A tuple `{:noreply, socket}` indicating that the event was handled successfully.

  """
  def handle_event("start", %{"vs" => vs}, socket) do
    {:noreply, redirect(socket, to: "/#{random_code()}/#{vs}")}
  end

  @spec random_code() :: String.t()
  @doc """
  Generates a random game code.

  This function generates a random game code by creating a string of random bytes and converting it to a hexadecimal string.

  ## Returns

  A random game code as a string.

  """
  defp random_code() do
    :crypto.strong_rand_bytes(5)
    |> :binary.bin_to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
  end
end
