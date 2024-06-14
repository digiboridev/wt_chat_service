defmodule WTChatWeb.ChatMemberController do
  use WTChatWeb, :controller
  alias WTChat.ChatMemberService

  action_fallback WTChatWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    chat_members = ChatMemberService.index()
    render(conn, :index, chat_members: chat_members)
  end

  def index_by_chat(conn, %{"chat_id" => chat_id}) do
    chat_members = ChatMemberService.index_by_chat_id(chat_id)
    render(conn, :index, chat_members: chat_members)
  end
end
