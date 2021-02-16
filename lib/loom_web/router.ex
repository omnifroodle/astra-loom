defmodule LoomWeb.Router do
  use LoomWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LoomWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Our pipeline implements "maybe" authenticated. We'll use the `:ensure_auth` below for when we need to make sure someone is logged in.
  pipeline :auth do
    plug Loom.Guardian.Pipeline
    plug Loom.Guardian.CurrentUserPlug
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", LoomWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    get "/auth/dev/callback", DevAuthController, :index

    get "/auth/google/callback", GoogleAuthController, :index
    live_dashboard "/dashboard", metrics: LoomWeb.Telemetry
  end

  # Definitely logged in scope
  scope "/", LoomWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    live "/chat", ChatLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LoomWeb do
  #   pipe_through :api
  # end
end
