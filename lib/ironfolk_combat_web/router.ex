defmodule IronfolkCombatWeb.Router do
  use IronfolkCombatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IronfolkCombatWeb.Layouts, :root}
    plug :put_layout, html: {IronfolkCombatWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IronfolkCombatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug IronfolkCombatWeb.Plugs.RequireAdmin
  end

  scope "/", IronfolkCombatWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/signup", SignupLive
    live "/events", EventsLive
    # live "/payment", PaymentLive
    # live "/payment/success", PaymentSuccessLive
    live "/blog", BlogIndexLive
    live "/ifn-lookup", IFNLookupLive
    live "/contact", ContactLive

    get "/about", PageController, :about
    get "/faq", PageController, :faq
    get "/resources", PageController, :resources
    get "/code-of-conduct", PageController, :code_of_conduct
    get "/harassment-policy", PageController, :sexual_harassment
    get "/blog/:slug", BlogController, :show
    get "/payment/cancel", PageController, :payment_cancel

    post "/signup", PageController, :create_signup
  end

  scope "/admin", IronfolkCombatWeb do
    pipe_through :browser
    get "/", AdminRedirectController, :index
    get "/login", AdminSessionController, :new
    post "/login", AdminSessionController, :create
    delete "/logout", AdminSessionController, :delete
    live "/register", AdminRegisterLive
  end

  scope "/admin", IronfolkCombatWeb.Admin, as: :admin do
    pipe_through :admin
    live "/dashboard", DashboardLive, :index
    live "/signups", SignupsLive, :index
    live "/blog", BlogLive, :index
    live "/blog/new", BlogLive, :new
    live "/alerts", AlertsLive, :index
    live "/alerts/new", AlertsLive, :new
    live "/events", EventsLive, :index
    live "/events/new", EventsLive, :new
    live "/messages", MessagesLive
    live "/members", MembersLive
    live "/payments", PaymentsLive
  end

  scope "/webhooks", IronfolkCombatWeb do
    post "/stripe", StripeWebhookController, :webhook
  end

  # Other scopes may use custom stacks.
  # scope "/api", IronfolkCombatWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ironfolk_combat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IronfolkCombatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
