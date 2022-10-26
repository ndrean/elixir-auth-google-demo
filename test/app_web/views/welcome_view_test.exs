defmodule AppWeb.WelcomeViewTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.View

  test "renders PAge" do
    assert render_to_string(
             AppWeb.WelcomeView,
             "index.html",
             profile: %{email: "email", given_name: "given_name", picture: "dwyl.com"}
           ) =~
             "signed in"
  end
end
