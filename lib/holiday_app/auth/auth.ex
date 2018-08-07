defmodule HolidayApp.Auth do
  alias HolidayApp.Users

  def authenticate(%Ueberauth.Auth{provider: :identity} = auth) do
    email = auth.info.email
    password = auth.credentials.other.password

    Users.find_by_email_and_password(email, password)
  end
end
