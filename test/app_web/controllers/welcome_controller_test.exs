# defmodule AppWeb.WelcomeControllerTest do
#   use AppWeb.ConnCase
#   require Logger
#   import Plug.Conn

#   test "GET /welcome", %{conn: conn} do
#     # conn =
#     #   assign(conn, :profile, %{
#     #     given_name: "given_name",
#     #     picture: "picture",
#     #     email: "email"
#     #   })

#     conn = get(conn, "/welcome")

#     assert html_response(conn, 200) =~ "You are signed in"
#   end
# end
