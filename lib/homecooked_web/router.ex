defmodule HomecookedWeb.Router do
  use HomecookedWeb, :router

  alias HomecookedWeb.BotAuthentication
  alias HomecookedWeb.UserAuthentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HomecookedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :bot do
    plug BotAuthentication
  end

  pipeline :app do
    plug UserAuthentication
  end

  scope "/", HomecookedWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login/magic-link/invalid", PageController, :invalid_magic_link
    get "/login/magic-link/:token", AuthController, :login_with_magic_link
  end

  scope "/app", HomecookedWeb do
    pipe_through [:browser, :app]

    live "/feed", LiveView.Feed
    live "/create", LiveView.Post.Create
    live "/profile", LiveView.Profile
  end

  scope "/api/bot", HomecookedWeb do
    pipe_through [:api, :bot]

    post "/magic-link", BotController, :generate_magic_link
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:homecooked, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HomecookedWeb.Telemetry
    end
  end
end
