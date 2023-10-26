defmodule V2TicTacToeWeb.ErrorJSONTest do
  use V2TicTacToeWeb.ConnCase, async: true

  test "renders 404" do
    assert V2TicTacToeWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert V2TicTacToeWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
