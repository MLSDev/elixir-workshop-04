defmodule HolidayApp.Users do
  @moduledoc """
  The Users context.
  """
  import Ecto.Query, warn: false

  alias HolidayApp.Repo
  alias HolidayApp.Users.User

  @doc """
  Lists all users
  """
  def list_users, do: Repo.all(User)

  @doc """
  Finds user by `id`.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Finds user by email/password combination.
  Returns `{:ok, user}` or `{:error, message}`.
  Note that the error message is meant to be used for logging purposes only; it should not be passed on to the end user.
  """
  def find_by_email_and_password(email, password) do
    User
    |> Repo.get_by(email: email)
    |> Comeonin.Argon2.check_pass(password)
  end
end
