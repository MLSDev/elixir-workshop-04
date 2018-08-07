defmodule HolidayApp.Auth do
  alias HolidayApp.Users

  @doc """
  Performs user authentication depending on `auth` provider and credentials.
  ## Return values
      * {:ok, %User{} = user}
      * {:error, reason}
  """
  def authenticate(auth)

  def authenticate(%Ueberauth.Auth{provider: :identity} = auth) do
    email = auth.info.email
    password = auth.credentials.other.password

    Users.find_by_email_and_password(email, password)
  end

  def authenticate(%Ueberauth.Auth{} = auth) do
    parse_auth(auth) |> Users.create_or_update_user()
  end

  defp parse_auth(%Ueberauth.Auth{} = auth) do
    %{
      provider: to_string(auth.provider),
      uid: auth.uid,
      email: auth.info.email
    }
  end
end
