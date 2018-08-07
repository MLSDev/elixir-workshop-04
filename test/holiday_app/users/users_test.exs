defmodule HolidayApp.UsersTest do
  use HolidayApp.DataCase

  alias HolidayApp.Users
  alias HolidayApp.Users.User

  describe "list_users/0" do
    test "returns all users" do
      insert_pair(:user)

      assert [%User{}, %User{}] = Users.list_users()
    end
  end

  describe "get_user!/1" do
    test "finds user by id" do
      %User{id: id} = insert(:user)

      assert %User{id: ^id} = Users.get_user!(id)
    end
  end

  describe "get_by_email_and_password/2" do
    setup do
      user =
        %User{}
        |> User.create_changeset(params_for(:user))
        |> Ecto.Changeset.apply_changes()
        |> insert()

      {:ok, user: user}
    end

    test "returns {:ok, user} on valid email and password", %{user: user} do
      assert {:ok, %User{id: id}} = Users.find_by_email_and_password(user.email, "P4$$w0rd")
      assert id == user.id
    end

    test "returns {:error, reason} on invalid credentials", %{user: user} do
      assert {:error, reason} = Users.find_by_email_and_password(user.email, "password")
      assert is_binary(reason)
    end
  end
end
