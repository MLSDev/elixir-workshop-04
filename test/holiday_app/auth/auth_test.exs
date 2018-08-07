defmodule HolidayApp.AuthTest do
  use HolidayApp.DataCase

  alias HolidayApp.Auth
  alias HolidayApp.Users.User

  describe "authenticate(auth) for :identity provider" do
    setup do
      user = insert_user_with_password("dummyPassword")
      {:ok, user: user}
    end

    def auth_struct(email, password) do
      %Ueberauth.Auth{
        credentials: %Ueberauth.Auth.Credentials{
          other: %{password: password}
        },
        info: %Ueberauth.Auth.Info{email: email},
        provider: :identity,
        strategy: Ueberauth.Strategy.Identity
      }
    end

    test "authenticates user with valid credentials", %{user: %User{id: id} = user} do
      auth = auth_struct(user.email, "dummyPassword")
      assert {:ok, %User{id: ^id}} = Auth.authenticate(auth)
    end

    test "rejects on invalid credentials", %{user: user} do
      auth = auth_struct(user.email, "wrong")
      assert {:error, _reason} = Auth.authenticate(auth)

      auth = auth_struct("mail@b.cc", "dummyPassword")
      assert {:error, _reason} = Auth.authenticate(auth)
    end
  end
end
