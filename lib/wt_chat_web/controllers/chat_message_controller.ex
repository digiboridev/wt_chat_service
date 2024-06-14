defmodule WTChatWeb.ChatMessageController do
  use WTChatWeb, :controller

  alias WTChat.Chats.ChatMessage
  alias WTChat.ChatMessageService

  action_fallback WTChatWeb.FallbackController

  def index_by_chat(conn, %{"chat_id" => chat_id}) do
    chat_messages = ChatMessageService.index_by_chat_id(chat_id)
    render(conn, :index, chat_messages: chat_messages)
  end

  def create(conn, %{"chat_id" => chat_id, "chat_message" => params}) do
    chat_id_number = String.to_integer(chat_id)
    params = Map.put(params, "chat_id", chat_id_number)

    with {:ok, %ChatMessage{} = chat_message} <- ChatMessageService.create(params) do
      conn
      |> put_status(:created)
      |> render(:show, chat_message: chat_message)
    end
  end

  def edit(conn, %{"id" => id, "content" => content}) do
    with {:ok, %ChatMessage{} = chat_message} <- ChatMessageService.edit(id, content) do
      render(conn, :show, chat_message: chat_message)
    end
  end

  def soft_delete(conn, %{"id" => id}) do
    with {:ok, %ChatMessage{} = chat_message} <- ChatMessageService.soft_delete(id) do
      render(conn, :show, chat_message: chat_message)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %ChatMessage{}} <- ChatMessageService.delete(id) do
      send_resp(conn, :no_content, "")
    end
  end
end
