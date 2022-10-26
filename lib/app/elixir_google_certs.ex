defmodule App.ElixirGoogleCerts do
  @moduledoc """
  The received JWT is checked for integrity versus
  Google's public keys JWK.
  This is based on the Joken library.
  It exposes one function: verifed_identity/1
  """
  @g_certs3_url "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"
  @g_app_id System.get_env("GOOGLE_CLIENT_ID")

  @doc """
  Receives a JWT token from Google and delivers
  the users' credentials in case of success:
  {:ok,
    %{
      email: "harry@potter.com,
      name: "Harry Potter,
      give_name: "Harry",
      google_id: "123456",
      picture: "https://somehwere",
    }
  }
  """
  def verified_identity(jwt) do
    module =
      (Application.get_env(:app, :mode) == :test && App.MockIdentity) ||
        App.ElixirGoogleCerts

    with {:ok,
          %{
            "aud" => aud,
            "azp" => azp,
            "email" => email,
            "iss" => iss,
            "name" => name,
            "picture" => pic,
            "given_name" => given_name,
            "sub" => sub
          }} <- module.check_identity(jwt),
         true <- module.check_user(aud, azp),
         true <- module.check_iss(iss) do
      {:ok, %{email: email, name: name, google_id: sub, picture: pic, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, :wrong_check}
    end
  end

  # We retrieve Google's public certs JWK format
  # to check the signature of the received token
  def check_identity(jwt) do
    case Joken.peek_header(jwt) do
      {:error, msg} ->
        {:error, msg}

      {:ok, %{"kid" => kid, "alg" => alg}} ->
        %{"keys" => certs} =
          @g_certs3_url
          |> HTTPoison.get!()
          |> Map.get(:body)
          |> Jason.decode!()

        cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)

        signer = Joken.Signer.create(alg, cert)

        Joken.verify(jwt, signer, [])
    end
  end

  # ---- Google post-checking recommendations
  def check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  def check_iss(iss), do: iss == @iss
  def aud, do: @g_app_id
end
