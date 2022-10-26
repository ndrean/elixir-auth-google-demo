defmodule AppWeb.GoogleAuthControllerTest do
  use AppWeb.ConnCase

  test "bad token", %{conn: conn} do
    assert AppWeb.GoogleAuthController.index(conn, %{"code" => 1}) ==
             {:error, :invalid_code_value}
  end
end
