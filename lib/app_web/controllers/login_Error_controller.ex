defmodule AppWeb.LoginError do
  use AppWeb, :controller
  require Logger

  @moduledoc """
  Fallback for GoogleAuthCtrl and OneTapCtrl errors, returns to "/" and display flash error
  """
  def call(conn, {:error, message}) do
    Logger.warning(inspect(message))

    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, message)
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end

  def call(conn, error) do
    IO.inspect(error)
  end
end

# nb: first call fetch_session, then fetch_flash, in THIS order
