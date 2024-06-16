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
    get "/chats/find_dialog", ChatController, :find_dialog
    get "/chats/:id", ChatController, :show
    patch "/chats/:id", ChatController, :update
    delete "/chats/:id", ChatController, :soft_delete
    post "/chats/:id/leave", ChatController, :leave_chat
    post "/chats/:id/member_add", ChatController, :add_member
    post "/chats/:id/member_block", ChatController, :block_member

    get "/chats/:chat_id/message_history", ChatMessageController, :message_history
    get "/chats/:chat_id/message_updates", ChatMessageController, :message_updates
    post "/chats/:chat_id/messages", ChatMessageController, :create
    patch "/chats/:chat_id/messages/:id", ChatMessageController, :edit
    delete "/chats/:chat_id/messages/:id", ChatMessageController, :soft_delete

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
