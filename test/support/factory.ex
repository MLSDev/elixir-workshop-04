defmodule HolidayApp.Factory do
  use ExMachina.Ecto, repo: HolidayApp.Repo

  alias HolidayApp.Holidays.Holiday
  alias HolidayApp.Users.User

  def holiday_factory do
    %Holiday{
      date: random_date(),
      title: sequence(:title, &"Holiday title #{&1}"),
      kind: "holiday"
    }
  end

  def workday_factory do
    %{holiday_factory() | kind: "workday"}
  end

  def user_factory do
    %User{
      email: sequence(:email, &"email#{&1}@domain.com"),
      password: "P4$$w0rd",
      password_confirmation: "P4$$w0rd"
    }
  end

  defp random_date do
    day = Enum.random(1..28)
    month = Enum.random(1..12)
    year = Enum.random(2009..2099)
    {:ok, date} = Date.new(year, month, day)
    date
  end
end
