defmodule HolidayApp.Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password_hash, :string

    field :uid, :string
    field :provider, :string, default: "identity"

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @required_identity_fields [:provider, :email, :password, :password_confirmation]
  @required_fields          [:provider, :email, :uid]

  @changeable_fields [
    :uid,
    :provider,
    :password,
    :password_confirmation
  ]

  @doc false
  def create_changeset(struct, attrs)

  def create_changeset(struct, %{provider: "identity"} = attrs) do
    struct
    |> cast(attrs, @required_identity_fields)
    |> validate_required(@required_identity_fields)
    |> validate_email(:email)
    |> verify_password()
  end

  def create_changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:uid)
    |> validate_email(:email)
  end

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @changeable_fields)
    |> unique_constraint(:uid)
    |> validate_inclusion(:provider, ["identity", "google"])
    |> verify_password()
  end

  defp validate_email(changeset, field) do
    changeset
    |> validate_format(field, ~r/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
    |> unique_constraint(field)
  end

  defp verify_password(changeset) do
    changeset
    |> validate_length(:password, min: 8, max: 64)
    |> validate_confirmation(:password, message: "does not match password")
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end
  defp put_pass_hash(changeset), do: changeset
end
