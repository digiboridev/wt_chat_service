defmodule WTChatWeb.ChatController do
  use WTChatWeb, :controller

  alias WTChat.Chats
  alias WTChat.Chats.Chat

  action_fallback WTChatWeb.FallbackController

  def index(conn, params) do
    member_filter = Map.get(params, "member_id")
    updated_at_filter = Map.get(params, "updated_at")

    chats = case {member_filter, updated_at_filter} do
      {nil, nil} -> Chats.list_chats()
      {member_id, nil} -> Chats.list_chats(member_id)
      {member_id, updated_at} -> Chats.list_chats(member_id, updated_at)
    end
    render(conn, :index, chats: chats)
  end

  @spec create(atom() | %{:body_params => any(), optional(any()) => any()}, any()) :: any()
  def create(conn, %{"chat" => chat_params}) do

    # append joined_at to each member
    chat_params = Map.put(chat_params, "members", append_members_join_date(chat_params["members"]))

    with {:ok, %Chat{} = chat} <- Chats.create_chat(chat_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/chats/#{chat}")
      |> render(:show, chat: chat)
    end
  end

  def show(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    render(conn, :show, chat: chat)
  end

  def update(conn, %{"id" => id, "chat" => chat_params}) do
    chat = Chats.get_chat!(id)

    # append joined_at to each new member
    chat_params = Map.put(chat_params, "members", append_members_join_date(chat_params["members"]))

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params) do
      render(conn, :show, chat: chat)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)

    with {:ok, %Chat{}} <- Chats.delete_chat(chat) do
      send_resp(conn, :no_content, "")
    end
  end

  def soft_delete(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    chat_params = %{"deleted_at" => NaiveDateTime.utc_now()}

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params) do
      render(conn, :show, chat: chat)
    end
  end

  def append_members_join_date(members) do
    Enum.map(members, fn member ->
      case member["joined_at"] do
        nil -> Map.put(member, "joined_at", DateTime.utc_now())
        _ -> member
      end
     end
     )
  end
end
