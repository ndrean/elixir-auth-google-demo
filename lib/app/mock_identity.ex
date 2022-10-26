defmodule App.MockIdentity do
  @iss "https://accounts.google.com"
  @g_app_id System.get_env("GOOGLE_CLIENT_ID")

  def check_identity("ok") do
    {:ok,
     %{
       "aud" => @g_app_id,
       "azp" => @g_app_id,
       "email" => "harry@potter.com",
       "iss" => @iss,
       "name" => "Harry Potter",
       "picture" => "https://dwyl.com",
       "given_name" => "Harry",
       "sub" => "123"
     }}
  end

  def check_identity("bad aud") do
    {:ok,
     %{
       "aud" => "aud",
       "azp" => "azp",
       "email" => "harry@potter.com",
       "iss" => @iss,
       "name" => "Harry Potter",
       "picture" => "https://dwyl.com",
       "given_name" => "Harry",
       "sub" => "123"
     }}
  end

  def check_identity("bad iss") do
    {:ok,
     %{
       "aud" => @g_app_id,
       "azp" => @g_app_id,
       "email" => "harry@potter.com",
       "iss" => "iss",
       "name" => "Harry Potter",
       "picture" => "https://dwyl.com",
       "given_name" => "Harry",
       "sub" => "123"
     }}
  end

  def check_identity("123"), do: {:error, :token_malformed}

  def check_identity(_) do
    {:ok,
     %{
       "aud" => @g_app_id,
       "azp" => @g_app_id,
       "email" => "harry@potter.com",
       "iss" => @iss,
       "name" => "Harry Potter",
       "picture" => "https://dwyl.com",
       "given_name" => "Harry",
       "sub" => "123"
     }}
  end

  def check_user(@g_app_id, _), do: true
  def check_user(_, @g_app_id), do: true
  def check_user(_, _), do: false

  def check_iss(@iss), do: true
  def check_iss(_), do: false
end
