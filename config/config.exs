# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :holiday_app,
  ecto_repos: [HolidayApp.Repo]

# Configures the endpoint
config :holiday_app, HolidayAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UzNHCN/fEhHRUHXjx6iKQpz9ZIj8UHyU7VQh9lkOYKwRB02ntgitVWGneP+fBo/Z",
  render_errors: [view: HolidayAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HolidayApp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
