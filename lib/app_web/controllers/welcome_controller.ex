defmodule AppWeb.WelcomeController do
  use AppWeb, :controller

  def index(conn, _p) do
    profile = get_session(conn, :profile)

    render(conn, "index.html", profile: profile)
    |> IO.inspect()
  end
end
