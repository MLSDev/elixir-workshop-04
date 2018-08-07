defmodule HolidayApp.Users.UserTest do
  use HolidayApp.DataCase

  alias HolidayApp.Users.User
  alias HolidayApp.Repo

  describe "create_changeset/2" do
    test "valid attributes" do
      attrs = params_for(:user)
      changeset = User.create_changeset(%User{}, attrs)
      assert changeset.valid?
    end

    test "does not accept password_hash" do
      attrs = params_for(:user, %{
        email: "a@b.cc",
        password: nil,
        password_confirmation: nil,
        password_hash: "hash"
      })
      changeset = User.create_changeset(%User{}, attrs)
      refute changeset.changes[:password_hash]
    end

    test "requires email" do
      attrs = params_for(:user, email: "")
      changeset = User.create_changeset(%User{}, attrs)
      assert {
        :email, { "can't be blank", [validation: :required] }
      } in changeset.errors
    end

    test "validates email format" do
      attrs = params_for(:user, email: "mail.domain.com")
      changeset = User.create_changeset(%User{}, attrs)
      assert "has invalid format" in errors_on(changeset).email
    end

    test "validates email uniqueness" do
      insert(:user, email: "mail@server.com")
      attrs = params_for(:user, email: "mail@server.com")
      {:error, changeset} = User.create_changeset(%User{}, attrs) |> Repo.insert
      assert "has already been taken" in errors_on(changeset).email
    end

    test "requires password" do
      attrs = params_for(:user, password: "")
      changeset = User.create_changeset(%User{}, attrs)
      assert {
        :password, { "can't be blank", [validation: :required] }
      } in changeset.errors
    end

    test "validates password length" do
      attrs = params_for(:user, password: "Yo")
      changeset = User.create_changeset(%User{}, attrs)
      assert "should be at least 8 character(s)" in errors_on(changeset).password

      attrs = params_for(:user, password: String.duplicate("a", 65))
      changeset = User.create_changeset(%User{}, attrs)
      assert "should be at most 64 character(s)" in errors_on(changeset).password
    end

    test "requires password_confirmation" do
      attrs = params_for(:user, password_confirmation: "")
      changeset = User.create_changeset(%User{}, attrs)
      assert {
        :password_confirmation, { "can't be blank", [validation: :required] }
      } in changeset.errors
    end

    test "validates password confirmation" do
      attrs = params_for(:user, password: "P4$$w0rd", password_confirmation: "pass")
      changeset = User.create_changeset(%User{}, attrs)
      assert {
        :password_confirmation, { "does not match password", [validation: :confirmation]}
        } in changeset.errors
    end

    test "encrypts password" do
      attrs = params_for(:user)
      %Ecto.Changeset{valid?: true, changes: %{password_hash: hash}} = User.create_changeset(%User{}, attrs)
      assert hash
      assert Comeonin.Argon2.checkpw("P4$$w0rd", hash)
    end
  end
end
