<div align="center">

# `elixir-auth-google` _demo_

A basic example of using Google Auth in a Phoenix App with two methods.

[![Build Status](https://img.shields.io/travis/com/dwyl/elixir-auth-google-demo/master?color=bright-green&style=flat-square)](https://travis-ci.com/github/dwyl/elixir-auth-google-demo)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/elixir-auth-google/master.svg?style=flat-square)](http://codecov.io/github/dwyl/elixir-auth-google?branch=master)
![Hex.pm](https://img.shields.io/hexpm/v/elixir_auth_google?color=brightgreen&style=flat-square)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/elixir-auth-google/issues)

> Try it: https://elixir-auth-google-demo.herokuapp.com

:exclamation: maybe update with One tap ?? :exclamation:

</div>

# _Why_? 🤷

As developers, we are _always learning_ new things.
When we learn, we love having _detailed docs and **examples**_
that explains _exactly_ how to get up and running.
We write examples because we want them _ourselves_,
if you find them useful, please :star: the repo to let us know.

# _What_? 💭

This project is intended as a _barebones_ demonstration of using the module [`elixir-auth-google`](https://github.com/dwyl/elixir-auth-google) to add support for "**_Sign-in with Google_**" to any Phoenix Application.

We also demonstrate how to use the [**One tap**](https://developers.google.com/identity/gsi/web/guides/overview) login, the latest authentication functionality from Google.

# _Who_? 👥

This demo is intended for people of all Elixir/Phoenix skill levels.
Anyone who wants the "**_Sign-in with Google_**" functionality
without the extra steps to configure a whole auth _framework_.

Following all the steps in this example should take around 10 minutes.
However, if you get stuck, please don't suffer in silence!
Get help by opening an issue: https://github.com/dwyl/elixir-auth-google/issues

# _How?_ 💻

This example follows the step-by-instructions in the docs
[github.com/dwyl/elixir-auth-google](https://github.com/dwyl/elixir-auth-google) to set up a Google Login.

## 1. Add the `elixir_auth_google` package to `mix.exs` 📦

Open your `mix.exs` file and add the following line to your `deps` list:

```elixir
def deps do
  [
    {:elixir_auth_google, "~> 1.6"}
  ]
end
```

Run the **`mix deps.get`** command to download.

## 2. Create the Google APIs Application OAuth2 Credentials ✨

Create your Google App and download the API keys by following the instructions:

[`/create-google-app-guide.md`](https://github.com/dwyl/elixir-auth-google/blob/master/create-google-app-guide.md)

By the end of this step, you should have these two environment variables defined: :id:

```bash
# .env
export GOOGLE_CLIENT_ID="6317...apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="MHxv6-RGF..."
```

:exclamation: Run `source .env`

## 3. Create 2 New Files ➕

We need to create two files to handle the requests to the Google Auth API and display data to people using our app.

### 3.1. Create a `GoogleAuthController` in your Project

To process and _display_ the data returned by the Google OAuth2 API, we need to create a new `controller`.

Create a new file and add this code:

```elixir
# lib/app_web_controllers/googe_auth_controller.ex

defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller
  action_fallback AppWeb.LoginError

  def index(conn, %{"code" => code}) do
    with {:ok, token} = ElixirAuthGoogle.get_token(code, conn),
        {:ok, profile} =
          ElixirAuthGoogle.get_user_profile(token.access_token) do
      conn
      |> put_view(AppWeb.PageView)
      |> render(:welcome, profile: profile)
    end
  end
end
```

This code does 4 things:

- Creates a one-time auth token based on the response `code` sent by Google after the person authenticates.
- Requests the person's profile data from Google based on the `access_token`.
- Renders a `:welcome` view displaying some profile data
  to confirm that login with Google was successful.
- Defines a [fallback action](https://hexdocs.pm/phoenix/Phoenix.Controller.html#action_fallback/1) to trap errors.

> Note: we are placing the `welcome.html.heex` template
> in the `template/page` directory to save having to create another controller and view files.
> With this, we only need to create the "Welcome" template for now.
> You are free to organise your code however you prefer.
> If you use the **One tap** snippet (see further below), you will _need_ to create the Welcome flow (controller, view and a copy of the template).

### 3.2. Create `welcome` template 📝

Create a new file with the following path:
`lib/app_web/templates/page/welcome.html.eex`

And type (_or paste_) the following code in it:

```html
<section class="phx-hero">
  <h1>
    Welcome <%= @profile.given_name %>!
    <img width="32px" src="<%= @profile.picture %>" />
  </h1>
  <p>
    You are <strong>signed in</strong> with your
    <strong>Google Account</strong> <br />
    <strong style="color:teal;"><%= @profile.email %></strong>
  </p>

  <p />
</section>
```

The Google Auth API `get_profile` request
returns profile data in the following format:

```elixir
%{
  email: "nelson@gmail.com",
  email_verified: true,
  family_name: "Correia",
  given_name: "Nelson",
  locale: "en",
  name: "Nelson Correia",
  picture: "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7",
  sub: "940732358705212133793"
}
```

You can use this data however you see fit.
(_treat it with respect, only store what you need and keep it secure_)

## 4. Add the `/auth/google/callback` to `router.ex`

Open your `lib/app_web/router.ex` file
and locate the section that looks like `scope "/", AppWeb do`

Add the following line:

```elixir
get "/auth/google/callback", GoogleAuthController, :index
```

That will direct the API request response
to the `GoogleAuthController` `:index` function we defined above.

## 5. Update `PageController.index`

To display the "Sign-in with Google" button in the UI,
we need to _generate_ the URL for the button in the relevant controller,
and pass it to the template.

Open the `lib/app_web/controllers/page_controller.ex` file
and update the `index` function:

```elixir
# lib/app_web/controllers/page_controller.ex

def index(conn, _params) do
  with {:ok, token} <- App.ElixirAuthGoogle.get_token(code, conn),
      {:ok, profile} <- App.ElixirAuthGoogle.get_user_profile(token.access_token) do
    conn
    |> put_view(AppWeb.PageView)
    |> render(:welcome, profile: profile)
  end
end
```

### 5.1 Update the `page/index.html.eex` Template

Open the `/lib/app_web/templates/page/index.html.eex` file
and type the following code:

```html
<section class="phx-hero">
  <h1>Welcome to Awesome App!</h1>
  <p>To get started, login to your Google Account:</p>
  <p>
    <a href="<%= @oauth_google_url %>">
      <img src="https://i.imgur.com/Kagbzkq.png" alt="Sign in with Google" />
    </a>
  </p>
</section>
```

The home page of the app now has a big "Sign in with Google" button:

![sign-in-button](https://user-images.githubusercontent.com/194400/70202961-3c32c880-1713-11ea-9737-9121030ace06.png)

Once the person completes their authentication with Google,
they should see the following welcome message:

![welcome](https://user-images.githubusercontent.com/194400/70201692-494db880-170f-11ea-9776-0ffd1fdf5a72.png)

## 6 Use the One tap login

### 6.0 Copy the module `ElixirGoogleCerts` into your project

The module `ElixirGoogleCerts` is **mandatory**.
Unlike `Elixir-auth-google`, this small snippet it is not packaged in Hex.

> This module verifies the validity of the JWT you will receive against Google's public keys and extracts the user's credentials from it.

To use it in your project:

- **copy** :scissors: the file `/lib/app/elixir_google_certs.ex` found in this example into your code,
  or
- **copy** :scissors: the code **[at the end](#elixirgooglecerts-module-for-one-tap)** of this Readme into a file with the same name.

### 6.1 Add the "Login with Google" Button to your Template ✨

The "PageController" is untouched. We will only update the template it renders to add the **One tap** snippet.

![one-tap-login](priv/static/images/one_tap.png)

```html
# /lib/app_web/templates/page/index.html.heex

<script
  src="https://accounts.google.com/gsi/client"
  async defer>
</script>

<div id="g_id_onload"
  data-client_id={System.get_env("GOOGLE_CLIENT_ID")}
  data-login_uri="http://localhost:4000/auth/google/callback"
  data-auto_prompt="true"
  >
</div>
<div class="flex items-center">
  <div class="g_id_signin"
    data-type="standard"
    data-size="large"
    data-theme="outline"
    data-text="sign_in_with"
    data-shape="rectangular"
    data-logo_alignment="left">
  </div>
</div>
```

It loads Google's SDK, reads Google's credentials :id: and exposes an endpoint, the URI of the login endpoint of your **own web app**.

> **Note about the URI**: Google asks for an **absolute path**. You must use the **same** URL as the one you used in the **Google console**.

You can fill directly the URI in the template as above, or instead use Javascript: it will be "automatically filled with the context value).

Open your **`app.js`** file and add the code (instead of filling the dataset above):

```js
// app.js

const oneTap = document.querySelector("#g_id_onload");

if (oneTap) {
  oneTap.dataset.login_uri = window.location.href + "/auth/google/callback";
}
```

### 6.2 Create the `/auth/one_tap` Endpoint 📍

Google will `POST` :mailbox_with_mail: a JWT to your app after the Login dialogue.

Open your **`router.ex`** file and locate the section that looks like `pipeline :api"`.

Add there a new `POST` endpoint:

```elixir
# router.ex

pipeline :api do
  plug(:accepts, ["json"])

  post("/auth/one_tap",
    AppWeb.OneTapController,
    :index
  )
end
```

### 6.3. Create a `OneTapController` in your Project :new:

To process the JWT, create a new controller to respond to this new endpoint:

```elixir
# lib/app_web/controllers/one_tap_controller.ex

defmodule AppWeb.OneTapController do
  use AppWeb, :controller
  action_fallback AppWeb.LoginError

  def index(conn, %{"credential" => jwt}) do
    with {:ok, profile} <-
      App.ElixirGoogleCerts.verified_identity(jwt) do

    conn
    |> fetch_session()
    |> put_session(:profile, profile)
    |> redirect(to: Routes.welcome_path(conn, :index))
    end
  end
end
```

This code does 4 things:

- receives a one-time auth `jwt` sent by Google after the user authenticates,
- verifies the `jwt` against Google's public key and retrieves the users' credentials. This uses the module `GoogleCerts` located at `/lib/app/google_certs.ex`
- redirects to the `welcome` controller to display some profile data to confirm that login with Google was successful,
- or redirects to the fallback page on error.

### 6.4 Create the `welcome` flow :new:

Instead of being able to render directly from the callback controller as in the previous case, we need an extra step here since it is the browser that directed us.

We just need to create the "welcome" flow that was omitted above. This means we add a controller, a view and reuse the template.

- create a new controller:

```elixir
# lib/app_web/controllers/welcome_controller.ex

defmodule AppWeb.WelcomeController do
  use AppWeb, :controller

  def index(conn, _p) do
    profile = get_session(conn, :profile)
    render(conn, "index.html", profile: profile)
  end
end
```

- create a "welcome" view:

```elixir
# lib/app_web/views/welcome_view.ex

defmodule AppWeb.WelcomeView do
  use AppWeb, :view
end
```

- reuse the template "welcome" but into a different folder:

```elixir
# lib/app_web/templates/welcome/index.html.heex
<section class="phx-hero">
  <h1> Welcome <%= @profile.given_name %>!
  <img width="32px" src={@profile.picture} >
  </h1>
  <p> You are <strong>signed in</strong>
    with your <strong>Google Account</strong> <br />
    <strong style="color:teal;"><%= @profile.email %></strong>
  </p>
</section>
```

### 6.5 Error handler :x:

For good measure, we used an error fallback controller.
In case of an error in the callback controller, the directive `action_fallback` will direct the flow to this error controller.

```elixir
defmodule AppWeb.LoginError do
  use AppWeb, :controller
  require Logger

  def call(conn, {:error, message}) do
    Logger.warning(inspect(message))
    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, message)
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end
```

Et voilà! :rocket:

### `ElixirGoogleCerts` module for One tap

```elixir
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
          }} <- check_identity(jwt),
         true <- check_user(aud, azp),
         true <- check_iss(iss) do
      {:ok, %{email: email, name: name, google_id: sub, picture: pic, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, "wrong check"}
    end
  end

  # We retrieve Google's public certs JWK format
  # to check the signature of the received token
  defp check_identity(jwt) do
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
  defp check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  defp check_iss(iss), do: iss == @iss
  defp aud, do: @g_app_id
end
```
