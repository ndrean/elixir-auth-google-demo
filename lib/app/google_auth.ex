defmodule App.AuthGoogle do
  @google_auth_url "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"
  @google_token_url "https://oauth2.googleapis.com/token"
  @google_user_profile "https://www.googleapis.com/oauth2/v3/userinfo"
  @default_scope "profile email"
  @default_callback_path "/auth/google/callback"

  @httpoison (Application.compile_env(:elixir_auth_google, :httpoison_mock) &&
                ElixirAuthGoogle.HTTPoisonMock) || HTTPoison

  @type conn :: map

  @doc """
  `inject_poison/0` injects a TestDouble of HTTPoison in Test
  so that we don't have duplicate mock in consuming apps.
  see: https://github.com/dwyl/elixir-auth-google/issues/35
  """
  def inject_poison, do: @httpoison

  @doc """
  `get_baseurl_from_conn/1` derives the base URL from the conn struct
  """
  @spec get_baseurl_from_conn(conn) :: String.t()
  def get_baseurl_from_conn(%{host: h, port: p}) when h == "localhost" do
    "http://#{h}:#{p}"
  end

  def get_baseurl_from_conn(%{host: h}) do
    "https://#{h}"
  end

  @doc """
  `generate_redirect_uri/1` generates the Google redirect uri based on conn
  """
  @spec generate_redirect_uri(conn) :: String.t()
  def generate_redirect_uri(conn) do
    get_baseurl_from_conn(conn) <> get_app_callback_url()
  end

  @doc """
  `generate_oauth_url/1` creates the Google OAuth2 URL with client_id, scope and
  redirect_uri which is the URL Google will redirect to when auth is successful.
  This is the URL you need to use for your "Login with Google" button.
  See step 5 of the instructions.
  """
  @spec generate_oauth_url(conn) :: String.t()
  def generate_oauth_url(conn) do
    query = %{
      client_id: google_client_id(),
      scope: google_scope(),
      redirect_uri: generate_redirect_uri(conn)
    }

    params = URI.encode_query(query, :rfc3986)

    "#{@google_auth_url}&#{params}"
  end

  @doc """
  Same as `generate_oauth_url/1` with `state` query parameter
  """
  def generate_oauth_url(conn, state) when is_binary(state) do
    params = URI.encode_query(%{state: state}, :rfc3986)
    generate_oauth_url(conn) <> "&#{params}"
  end

  @doc """
  `get_token/2` encodes the secret keys and authorization code returned by Google
  and issues an HTTP request to get a person's profile data.
  **TODO**: we still need to handle the various failure conditions >> issues/16
  """

  def get_profile(code, conn) do
    Jason.encode!(%{
      client_id: google_client_id(),
      client_secret: google_client_secret(),
      redirect_uri: generate_redirect_uri(conn),
      grant_type: "authorization_code",
      code: code
    })
    |> then(fn body ->
      inject_poison().post(@google_token_url, body)
      |> parse_status()
    end)
    |> then(fn {status, response} ->
      case {status, response} do
        {:error, response} ->
          {:error, response}

        {:ok, response} ->
          get_user_profile(response.access_token)
      end
    end)
  end

  def get_user_profile(access_token) do
    access_token
    |> encode()
    |>then(fn params ->
      (@google_user_profile <> "?" <> params)
      |> inject_poison().get()
      |> parse_status()
    end)
  end

  def parse_status(request) do
    case request do
      {:ok, %{status_code: 200} = response} ->
        parse_body_response({:ok, response})

      {:ok, %{status_code: 404}} ->
        {:error, :wrong_url}

      {:ok, %{status_code: 401}} ->
        {:error, :unauthorized_with_bad_secret}

      {:ok, %{status_code: 400}} ->
        {:error, :bad_code}
    end
  end

  defp encode(token), do: URI.encode_query(%{access_token: token}, :rfc3986)
  ##################

  @doc """
  `parse_body_response/1` parses the response returned by Google
  so your app can use the resulting JSON.
  """
  @spec parse_body_response({atom, String.t()} | {:error, any}) :: {:ok, map} | {:error, any}
  def parse_body_response({:error, err}), do: {:error, err}

  def parse_body_response({:ok, response}) do
    body = Map.get(response, :body)
    # make keys of map atoms for easier access in templates
    if body == nil do
      {:error, :no_body}
    else
      {:ok, str_key_map} = Jason.decode(body)
      atom_key_map = for {key, val} <- str_key_map, into: %{}, do: {String.to_atom(key), val}
      {:ok, atom_key_map}
    end

    # https://stackoverflow.com/questions/31990134
  end

  defp google_client_id do
    System.get_env("GOOGLE_CLIENT_ID") || Application.get_env(:elixir_auth_google, :client_id)
  end

  defp google_client_secret do
    System.get_env("GOOGLE_CLIENT_SECRET") ||
      Application.get_env(:elixir_auth_google, :client_secret)
  end

  defp google_scope do
    System.get_env("GOOGLE_SCOPE") || Application.get_env(:elixir_auth_google, :google_scope) ||
      @default_scope
  end

  defp get_app_callback_url do
    System.get_env("GOOGLE_CALLBACK_PATH") ||
      Application.get_env(:elixir_auth_google, :callback_path) || @default_callback_path
  end
end
