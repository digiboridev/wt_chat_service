defmodule WTChatWeb.ChatController do
  use WTChatWeb, :controller

  alias WTChat.Chats
  alias WTChat.Chats.Chat

  action_fallback WTChatWeb.FallbackController

  def index(conn, _params) do
    chats = Chats.list_chats()
    render(conn, :index, chats: chats)
  end

  @spec create(atom() | %{:body_params => any(), optional(any()) => any()}, any()) :: any()
  def create(conn, %{"chat" => chat_params}) do

    # append joined_at to each member
    curernt_time = DateTime.utc_now()
    members = chat_params["members"]
    |> Enum.map(fn member -> Map.put(member, "joined_at", curernt_time) end)
    chat_params = Map.put(chat_params, "members", members)

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
end
