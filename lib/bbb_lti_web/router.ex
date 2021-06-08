defmodule BbbLtiWeb.Router do
  use BbbLtiWeb, :router
  import BbbLtiWeb.Plugs.AuthPlugs

  use Kaffy.Routes, scope: "/admin", pipe_through: [:require_admin_credentials]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
  end

  pipeline :security do
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fix_xframe_options
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug BasicAuth, use_config: {:bbb_lti, :auth_config}
  end

  scope "/", BbbLtiWeb do
    pipe_through [:browser, :security]

    get "/health", HealthController, :index
    resources "/login", LoginController, only: [:index, :create]
    delete "/login", LoginController, :delete
    resources "/meetings", MeetingController
    live "/calendar", CalendarLive, layout: {BbbLtiWeb.LayoutView, :app}
  end

  scope "/", BbbLtiWeb do
    pipe_through :browser

    post "/tool", ToolController, :validate_lti
  end

  # Other scopes may use custom stacks.
  scope "/api", BbbLtiWeb.Api, as: :api do
    pipe_through :api

    post "/lti/clients", ClientsController, :get_or_create
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BbbLtiWeb.Telemetry
    end
  end
end
