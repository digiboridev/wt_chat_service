defmodule WTChatWeb.ChatMessageController do
  use WTChatWeb, :controller

  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage

  action_fallback WTChatWeb.FallbackController

  def index(conn, _params) do
    chat_messages = Chats.list_chat_messages()
    render(conn, :index, chat_messages: chat_messages)
  end

  def create(conn, %{"chat_message" => chat_message_params}) do
    with {:ok, %ChatMessage{} = chat_message} <- Chats.create_chat_message(chat_message_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/chat_messages/#{chat_message}")
      |> render(:show, chat_message: chat_message)
    end
  end

  def show(conn, %{"id" => id}) do
    chat_message = Chats.get_chat_message!(id)
    render(conn, :show, chat_message: chat_message)
  end

  def update(conn, %{"id" => id, "chat_message" => chat_message_params}) do
    chat_message = Chats.get_chat_message!(id)

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(chat_message, chat_message_params) do
      render(conn, :show, chat_message: chat_message)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat_message = Chats.get_chat_message!(id)

    with {:ok, %ChatMessage{}} <- Chats.delete_chat_message(chat_message) do
      send_resp(conn, :no_content, "")
    end
  end
end
