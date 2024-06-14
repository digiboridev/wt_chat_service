defmodule WTChat.ChatMessageService do
  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage

  def index_by_chat_id(chat_id) do
    Chats.list_chat_messages_by_chat_id(chat_id)
  end

  def create(params) do
    with {:ok, %ChatMessage{} = chat_message} <- Chats.create_chat_message(params) do
      {:ok, chat_message}
    end
  end

  def edit(id,content) do
    chat_message = Chats.get_chat_message!(id)
    chat_message_params = %{"content" => content, "edited_at" => NaiveDateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(chat_message, chat_message_params) do
      {:ok, chat_message}
    end
  end

  def soft_delete(id) do
    chat_message = Chats.get_chat_message!(id)
    chat_message_params = %{"deleted_at" => NaiveDateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(chat_message, chat_message_params) do
      {:ok, chat_message}
    end
  end

  def delete(id) do
    chat_message = Chats.get_chat_message!(id)

    with {:ok, %ChatMessage{}} <- Chats.delete_chat_message(chat_message) do
      {:ok, chat_message}
    end
  end

end
