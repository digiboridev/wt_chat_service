defmodule WTChatWeb.ChatMemberController do
  use WTChatWeb, :controller

  alias WTChat.Chats

  action_fallback WTChatWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    chat_members = Chats.list_chat_members()
    render(conn, :index, chat_members: chat_members)
  end

  def index_by_chat(conn, %{"chat_id" => chat_id}) do
    chat_members = Chats.list_chat_members_by_chat_id(chat_id)
    render(conn, :index, chat_members: chat_members)
  end
end
