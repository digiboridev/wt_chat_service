defmodule WTChatWeb.ChatMessageController do
  use WTChatWeb, :controller

  alias WTChat.Chats.ChatMessage
  alias WTChat.ChatMessageService

  action_fallback WTChatWeb.FallbackController

  def message_history(conn, params) do
    chat_messages = ChatMessageService.message_history(params)
    render(conn, :index, chat_messages: chat_messages)
  end

  def message_updates(conn, params) do
    chat_messages = ChatMessageService.message_updates(params)
    render(conn, :index, chat_messages: chat_messages)
  end

  def create(conn, %{
        "chat_id" => chat_id,
        "content" => content,
        "sender_id" => sender_id,
        "idempotency_key" => id_key
      }) do
    chat_id_number = String.to_integer(chat_id)

    with {:ok, %ChatMessage{} = chat_message} <-
           ChatMessageService.new_message(
             chat_id_number,
             content,
             sender_id,
             id_key
           ) do
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
