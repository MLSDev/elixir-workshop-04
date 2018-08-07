defmodule HolidayAppWeb.Router do
  use HolidayAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HolidayAppWeb.AuthPipeline
  end

  scope "/", HolidayAppWeb do
    pipe_through :browser

    get "/", HomeController, :index

    get "/auth/new", AuthController, :new
    post "/auth/login", AuthController, :login
  end

  scope "/", HolidayAppWeb do
    pipe_through [:browser, Guardian.Plug.EnsureAuthenticated]

    delete "/auth/logout", AuthController, :logout
    resources "/holidays", HolidayController
  end
end
