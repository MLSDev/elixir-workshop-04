defmodule HolidayApp.AuthTest do
  use HolidayApp.DataCase

  alias HolidayApp.Auth
  alias HolidayApp.Users.User

  def auth_struct(:identity, email, password) do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{
        other: %{password: password}
      },
      info: %Ueberauth.Auth.Info{email: email},
      provider: :identity,
      strategy: Ueberauth.Strategy.Identity
    }
  end

  def auth_struct(:google, email, uid) do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{},
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          user: %{"hd" => "domain.com"}
        }
      },
      info: auth_struct_info(email),
      provider: :google,
      strategy: Ueberauth.Strategy.Google,
      uid: uid
    }
  end

  defp auth_struct_info(email) do
    %Ueberauth.Auth.Info{
      email: email,
      image: "https://xyz.google.com/1234/image.jpg",
      name: "Dick Mountain",
      first_name: "Dick",
      last_name: "Mountain"
    }
  end

  describe "authenticate(auth) for :identity provider" do
    setup do
      user = insert_user_with_password("dummyPassword")
      {:ok, user: user}
    end

    test "authenticates user with valid credentials", %{user: %User{id: id} = user} do
      auth = auth_struct(:identity, user.email, "dummyPassword")
      assert {:ok, %User{id: ^id}} = Auth.authenticate(auth)
    end

    test "rejects on invalid credentials", %{user: user} do
      auth = auth_struct(:identity, user.email, "wrong")
      assert {:error, _reason} = Auth.authenticate(auth)

      auth = auth_struct(:identity, "mail@b.cc", "dummyPassword")
      assert {:error, _reason} = Auth.authenticate(auth)
    end
  end

  describe "authenticate(auth) for non-identity provider" do
    setup do
      user = insert(:google_user)
      {:ok, user: user}
    end

    test "authenticates user with valid credentials", %{user: %User{id: id} = user} do
      auth = auth_struct(:google, user.email, user.uid)
      assert {:ok, %User{id: ^id}} = Auth.authenticate(auth)
    end

    test "authenticates user with invalid provider" do
      user = insert(:google_user)
      auth = 
        auth_struct(:google, user.email, user.uid)
        |>Map.put(:provider, :non_supported_provider)
      assert {:error, _reason} = Auth.authenticate(auth)
    end

    test "should use only name if full_name and last_name are nil", %{user: user} do
      info = 
        auth_struct_info(user.email)
        |> Map.put(:name, nil)
        |> Map.put(:last_name, nil)

      auth = 
        auth_struct(:google, user.email, user.uid)
        |> Map.put(:info, info)

      assert {:ok, user} = Auth.authenticate(auth)
      assert user.name == "Dick"
    end

    test "should use nickname if first_name and last_name are nil", %{user: user} do
      info = 
        auth_struct_info(user.email)
        |> Map.put(:name, nil)
        |> Map.put(:first_name, nil)
        |> Map.put(:last_name, nil)
        |> Map.put(:nickname, "Nickname")

      auth = 
        auth_struct(:google, user.email, user.uid)
        |> Map.put(:info, info)

      assert {:ok, user} = Auth.authenticate(auth)
      assert user.name == "Nickname"
    end

    test "should use last_name if first_name is nil", %{user: user} do
      info = 
        auth_struct_info(user.email)
        |> Map.put(:name, nil)
        |> Map.put(:first_name, nil)
        |> Map.put(:last_name, "Lastname")

      auth = 
        auth_struct(:google, user.email, user.uid)
        |> Map.put(:info, info)

      assert {:ok, user} = Auth.authenticate(auth)
      assert user.name == "Lastname"
    end

    test "parse default image", %{user: user} do
      auth = auth_struct(:google, user.email, user.uid)
      assert {:ok, user} = Auth.authenticate(auth)
      assert user.photo_url == "https://xyz.google.com/1234/image.jpg"
    end

    test "parse image", %{user: user} do
      info = 
        auth_struct_info(user.email)
        |> Map.delete(:image)
        |> Map.put(:urls, %{avatar_url: "https://example.com/images/1/image.jpg"})

      auth = 
        auth_struct(:google, user.email, user.uid)
        |> Map.put(:info, info) 
      assert {:ok, user} = Auth.authenticate(auth)
      assert user.photo_url == "https://example.com/images/1/image.jpg"
    end

    test "empty image", %{user: user} do
      info = 
        auth_struct_info(user.email)
        |> Map.delete(:image)
        |> Map.delete(:urls)

      auth = 
        auth_struct(:google, user.email, user.uid)
        |> Map.put(:info, info) 

      assert {:ok, user} = Auth.authenticate(auth)
      assert user.photo_url == nil
    end
  end
end
