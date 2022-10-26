defmodule AppWeb.PageViewTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.View

  test "renders PAge" do
    assert render_to_string(
             AppWeb.PageView,
             "index.html",
             oauth_google_url: "https://google.com"
           ) =~
             "Welcome to Awesome App"
  end
end
