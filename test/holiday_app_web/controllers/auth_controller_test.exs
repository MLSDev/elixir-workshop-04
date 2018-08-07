defmodule HolidayAppWeb.AuthControllerTest do
  use HolidayAppWeb.ConnCase

  alias HolidayAppWeb.AuthController
  alias HolidayApp.Users.User

  setup do
    conn = build_conn_with_session()

    user =
      build(:user)
      |> encrypt_password("dummyPassword")
      |> insert()

    {:ok, conn: conn, user: user}
  end

  describe "new" do
    test "renders form", %{conn: conn} do
      conn = get conn, auth_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "login" do
    test "logs user in", %{conn: conn, user: user} do
      conn = post conn, auth_path(conn, :login, email: user.email, password: "dummyPassword")
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~  "You have logged in"
    end

    test "denies on wrong password and renders login form", %{conn: conn, user: user} do
      conn = post conn, auth_path(conn, :login, email: user.email, password: "wrong")
      assert redirected_to(conn) == auth_path(conn, :new)
      assert get_flash(conn, :error) =~  "Invalid email/password combination"
    end
  end

  describe "logout" do
    test "logs user out", %{user: user} do
      conn = build_conn_and_login(user)
      conn = delete conn, auth_path(conn, :logout)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "You have logged out"
    end
  end

  describe "auth_error/3" do
    test "clears session, redirects to login page and puts message to flash" do
      conn =
        build_conn_with_session()
        |> put_session(:my_key, "my value")

      conn = AuthController.auth_error(conn, {:error, "Error message"}, [])

      refute get_session(conn, :my_key)
      assert redirected_to(conn) == auth_path(conn, :new)
      assert get_flash(conn, :error) == "Error message"
    end
  end

  defp encrypt_password(user, password) do
    user
    |> User.create_changeset(%{password: password, password_confirmation: password})
    |> Ecto.Changeset.apply_changes()
  end
end
