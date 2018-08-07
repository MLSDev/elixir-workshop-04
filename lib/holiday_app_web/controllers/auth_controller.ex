defmodule HolidayAppWeb.AuthController do
  use HolidayAppWeb, :controller

  alias HolidayApp.Users

  def new(conn, _params) do
    render(conn, :new)
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Users.find_by_email_and_password(email, password) do
      {:ok, user} ->
        conn
        |> HolidayAppWeb.Guardian.Plug.sign_in(user)
        |> put_flash(:info, "You have logged in!")
        |> redirect(to: "/")
      {:error, _reason} ->
        auth_error(conn, {:unauthorized, "Invalid email/password combination"}, [])
    end
  end

  def logout(conn, _params) do
    conn
    |> HolidayAppWeb.Guardian.Plug.sign_out()
    |> put_flash(:info, "You have logged out.")
    |> redirect(to: "/")
  end

  def auth_error(conn, {_type, reason}, _opts) do
    conn
    |> clear_session()
    |> put_flash(:error, reason)
    |> redirect(to: auth_path(conn, :new))
  end
end
