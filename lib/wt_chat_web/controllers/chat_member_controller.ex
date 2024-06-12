defmodule WTChatWeb.ChatMemberController do
  use WTChatWeb, :controller

  alias WTChat.Chats
  alias WTChat.Chats.ChatMember

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

  def create(conn, %{"chat_id" => chat_id, "chat_member" => chat_member_params}) do
    params = Map.put(chat_member_params, "chat_id", chat_id)

    # append joined_at to member
    current_time = DateTime.utc_now()
    params = Map.put(params, "joined_at", current_time)

    with {:ok, %ChatMember{} = chat_member} <- Chats.create_chat_member(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/chats/#{chat_id}/members/#{chat_member.id}")
      |> render(:show, chat_member: chat_member)
    end
  end

  def show(conn, %{"id" => id}) do
    chat_member = Chats.get_chat_member!(id)
    render(conn, :show, chat_member: chat_member)
  end

  def update(conn, %{"id" => id, "chat_member" => chat_member_params}) do
    chat_member = Chats.get_chat_member!(id)

    with {:ok, %ChatMember{} = chat_member} <-
           Chats.update_chat_member(chat_member, chat_member_params) do
      render(conn, :show, chat_member: chat_member)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat_member = Chats.get_chat_member!(id)

    with {:ok, %ChatMember{}} <- Chats.delete_chat_member(chat_member) do
      send_resp(conn, :no_content, "")
    end
  end
end
