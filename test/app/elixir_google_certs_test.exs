defmodule App.ElixirGoogleCertsTest do
  use ExUnit.Case, async: true

  @g_certs3_url "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"
  @g_app_id System.get_env("GOOGLE_CLIENT_ID")

  test "good credentials" do
    assert App.ElixirGoogleCerts.verified_identity("ok") ==
             {:ok,
              %{
                email: "harry@potter.com",
                name: "Harry Potter",
                picture: "https://dwyl.com",
                given_name: "Harry",
                google_id: "123"
              }}
  end

  test "unverified token" do
    assert App.ElixirGoogleCerts.verified_identity("123") == {:error, :token_malformed}
    assert App.ElixirGoogleCerts.verified_identity("bad iss") == {:error, :wrong_check}
    assert App.ElixirGoogleCerts.verified_identity("bad aud") == {:error, :wrong_check}
  end

  test "error in JWT" do
    assert App.ElixirGoogleCerts.check_identity("123") == {:error, :token_malformed}
    assert App.ElixirGoogleCerts.check_identity("bad aud") == {:error, :token_malformed}

    assert App.ElixirGoogleCerts.check_identity("bad azp") == {:error, :token_malformed}

    assert App.ElixirGoogleCerts.check_identity("bad iss") == {:error, :token_malformed}
  end

  test "good JWT" do
    assert {:ok, _} =
             App.ElixirGoogleCerts.check_identity(
               "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMWI5Zjg4Y2ZlMzE1MWRkZDI4NGE2MWJmOGNlY2Y2NTliMTMwY2YiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJuYmYiOjE2NjY3MjI1NzQsImF1ZCI6IjkzNTExMzk3MTgxMS1uZWJrbTA2aTBqbThqdG9lbnVsZDFzbXI5dnM2YWE4aC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjEwMTM3NTA5OTg5NDc1MzU0NDgxNiIsImVtYWlsIjoiZHJlYW5uZXZlbkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiOTM1MTEzOTcxODExLW5lYmttMDZpMGptOGp0b2VudWxkMXNtcjl2czZhYThoLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwibmFtZSI6Ik5ldmVuIERSRUFOIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FMbTV3dTBNeEZEVzRZTlVTSm5GR1pEdFhDMFRtT1AyY0s1LUpTcXVrclB1PXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6Ik5ldmVuIiwiZmFtaWx5X25hbWUiOiJEUkVBTiIsImlhdCI6MTY2NjcyMjg3NCwiZXhwIjoxNjY2NzI2NDc0LCJqdGkiOiJhMTkxMmNiMTBhYWZhY2UwNWU1ZmZmODViZjgxMWI3Zjk2YzZlMDlkIn0.Mnn_2BBV2FusnWooydbLwDfZt3A_XECYpyLvRWBj1vAt6ggdZRJei1DMlL8HrYQkbZSZIiDjIB8B_I1nguGDVpCPzv31QkmLxsTGznsW_lf5WvxKZI4GMiiI2xROy_7JTlWpBP0c3BmK4uZFKxItJJY7lF4KgVWOWPr1TQsOA0_nEDhsfP5Lgi5ZgKLyygyeijBmKwrX7Gn14KEpKB-1fcVA_eu9YwkPq6HUe9xHtTV85rCev189V-_58DnTcWazzNoIHUaMhWh-qaHulf7OCiXgwNIqyDqfu6RYMdrO1pjiN1iFEfvKgSRjivIpcti3HLLBDFhnW3x0u5Qg56BR_A"
             )

    assert {:ok, _} =
             App.ElixirGoogleCerts.verified_identity(
               "eyJhbGciOiJSUzI1NiIsImtpZCI6ImVlMWI5Zjg4Y2ZlMzE1MWRkZDI4NGE2MWJmOGNlY2Y2NTliMTMwY2YiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJuYmYiOjE2NjY3MjI1NzQsImF1ZCI6IjkzNTExMzk3MTgxMS1uZWJrbTA2aTBqbThqdG9lbnVsZDFzbXI5dnM2YWE4aC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjEwMTM3NTA5OTg5NDc1MzU0NDgxNiIsImVtYWlsIjoiZHJlYW5uZXZlbkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiOTM1MTEzOTcxODExLW5lYmttMDZpMGptOGp0b2VudWxkMXNtcjl2czZhYThoLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwibmFtZSI6Ik5ldmVuIERSRUFOIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FMbTV3dTBNeEZEVzRZTlVTSm5GR1pEdFhDMFRtT1AyY0s1LUpTcXVrclB1PXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6Ik5ldmVuIiwiZmFtaWx5X25hbWUiOiJEUkVBTiIsImlhdCI6MTY2NjcyMjg3NCwiZXhwIjoxNjY2NzI2NDc0LCJqdGkiOiJhMTkxMmNiMTBhYWZhY2UwNWU1ZmZmODViZjgxMWI3Zjk2YzZlMDlkIn0.Mnn_2BBV2FusnWooydbLwDfZt3A_XECYpyLvRWBj1vAt6ggdZRJei1DMlL8HrYQkbZSZIiDjIB8B_I1nguGDVpCPzv31QkmLxsTGznsW_lf5WvxKZI4GMiiI2xROy_7JTlWpBP0c3BmK4uZFKxItJJY7lF4KgVWOWPr1TQsOA0_nEDhsfP5Lgi5ZgKLyygyeijBmKwrX7Gn14KEpKB-1fcVA_eu9YwkPq6HUe9xHtTV85rCev189V-_58DnTcWazzNoIHUaMhWh-qaHulf7OCiXgwNIqyDqfu6RYMdrO1pjiN1iFEfvKgSRjivIpcti3HLLBDFhnW3x0u5Qg56BR_A"
             )
  end

  test "helpers" do
    assert App.ElixirGoogleCerts.aud() == @g_app_id
    assert App.ElixirGoogleCerts.check_user("a", "b") == false
    assert App.ElixirGoogleCerts.check_user(@g_app_id, "b") == true
    assert App.ElixirGoogleCerts.check_user("a", @g_app_id) == true
    assert App.ElixirGoogleCerts.check_iss("https://accounts.google.com") == true
    assert App.ElixirGoogleCerts.check_iss("https://account.google.com") == false
  end
end
