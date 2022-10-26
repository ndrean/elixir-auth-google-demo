defmodule AppWeb.OneTapControllerTest do
  use AppWeb.ConnCase

  test "controller halted with bad token", %{conn: conn} do
    body =
      conn
      |> Map.put(:host, "localhost")
      |> Map.put(:port, 4000)
      |> bypass_through(AppWeb.Router)
      |> post("/auth/one_tap", %{"credential" => "ok"})
      |> AppWeb.OneTapController.handle(%{"credential" => "ok"})
      |> Map.get(:resp_body)

    assert body == "<html><body>You are being <a href=\"/welcome\">redirected</a>.</body></html>"
  end
end
