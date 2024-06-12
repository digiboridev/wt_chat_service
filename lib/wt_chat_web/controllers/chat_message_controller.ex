defmodule WTChatWeb.ChatMessageController do
  use WTChatWeb, :controller

  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage

  action_fallback WTChatWeb.FallbackController

  def index(conn, _params) do
    chat_messages = Chats.list_chat_messages()
    render(conn, :index, chat_messages: chat_messages)
  end

  def index_by_chat(conn, %{"chat_id" => chat_id}) do
    chat_messages = Chats.list_chat_messages_by_chat_id(chat_id)
    render(conn, :index, chat_messages: chat_messages)
  end

  def create(conn, %{"chat_id" => chat_id, "chat_message" => chat_message_params}) do
    chat_id_number = String.to_integer(chat_id)
    chat_message_params = Map.put(chat_message_params, "chat_id", chat_id_number)

    with {:ok, %ChatMessage{} = chat_message} <- Chats.create_chat_message(chat_message_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/chat_messages/#{chat_message}")
      |> render(:show, chat_message: chat_message)
    end
  end

  def edit(conn, %{"id" => id, "content" => content}) do
    chat_message = Chats.get_chat_message!(id)
    chat_message_params = %{"content" => content, "edited_at" => NaiveDateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(chat_message, chat_message_params) do
      render(conn, :show, chat_message: chat_message)
    end
  end

  def soft_delete(conn, %{"id" => id}) do
    chat_message = Chats.get_chat_message!(id)
    chat_message_params = %{"deleted_at" => NaiveDateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(chat_message, chat_message_params) do
      render(conn, :show, chat_message: chat_message)
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
