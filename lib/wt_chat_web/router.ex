defmodule WTChatWeb.Router do
  use WTChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WTChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WTChatWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api", WTChatWeb do
    pipe_through :api

    get "/chats", ChatController, :index
    post "/chats", ChatController, :create

    get "/chats/:id", ChatController, :show
    put "/chats/:id", ChatController, :update
    delete "/chats/:id", ChatController, :delete

    get "/chats/:chat_id/members", ChatMemberController, :index_by_chat
    post "/chats/:chat_id/members", ChatMemberController, :create

    get "/chats/:chat_id/members/:id", ChatMemberController, :show
    put "/chats/:chat_id/members/:id", ChatMemberController, :update
    delete "/chats/:chat_id/members/:id", ChatMemberController, :delete

  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:wt_chat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WTChatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
