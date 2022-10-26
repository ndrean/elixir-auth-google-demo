defmodule AppWeb.OneTapController do
  @moduledoc """
  Callback to Google's answer
  """
  use AppWeb, :controller
  action_fallback AppWeb.LoginError

  def handle(conn, %{"credential" => jwt}) do
    with {:ok, profile} <-
           App.ElixirGoogleCerts.verified_identity(jwt) do
      conn
      |> fetch_session()
      |> put_session(:profile, profile)
      |> redirect(to: Routes.welcome_path(conn, :index))
    end
  end
end
