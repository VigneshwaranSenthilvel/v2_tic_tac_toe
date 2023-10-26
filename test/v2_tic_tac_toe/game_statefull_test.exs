defmodule V2TicTacToe.GameStatefullTest do
  use ExUnit.Case

  alias V2TicTacToe.GameStatefull

  setup do
    initial_state = %{
      id: "test_game",
      vs: "computer",
      game: GameStatefull.new_game(),
      winning_position: []
    }

    GameStatefull.start_link(initial_state)
    :ok
  end

  test "get/1 retrieves the game state" do
    assert %{:id => "test_game", :vs => "computer"} = GameStatefull.get("test_game")
  end

  test "update/2 updates the game state" do
    updated_state = GameStatefull.update("test_game", 5)
    assert updated_state.id == "test_game"
    assert updated_state.vs == "computer"
    assert Enum.at(updated_state.game.board, 1) == [nil, :player1, nil]
  end

  test "restart/1 restarts the game" do
    GameStatefull.update("test_game", 5)
    restarted_state = GameStatefull.restart("test_game")
    assert restarted_state.id == "test_game"
    assert Enum.at(restarted_state.game.board, 1) == [nil, nil, nil]
  end
end
