defmodule WTChat.ChatMessageService do
  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage
  alias WTChat.ChatService
  alias WTChat.Chats.Chat

  def message_history(chat_id, from, limit) do
    case {chat_id, from} do
      {nil, nil} -> Chats.message_history()
      {chat_id, nil} -> Chats.message_history(chat_id, limit)
      {chat_id, from} -> Chats.message_history(chat_id, from, limit)
    end
  end

  def message_updates(chat_id, from, limit) do
    case {from, chat_id} do
      {nil, nil} -> {:error, "from date required"}
      {from, nil} -> Chats.message_updates(from, limit)
      {from, chat_id} -> Chats.message_updates(from, limit, chat_id)
    end
  end

  def new_message(chat_id, content, sender_id, id_key) do
    msg_attr = %{
      content: content,
      chat_id: chat_id,
      sender_id: sender_id,
      idempotency_key: id_key
    }

    with {:ok, %ChatMessage{} = msg} <- Chats.create_chat_message(msg_attr) do
      publish_chat_message(msg)
      {:ok, msg}
    end
  end

  def new_dialog_message(from_id, to_id, content, id_key) do
    case ChatService.find_dialog(from_id, to_id) do
      # Try to find existing dialog that can be created in time gap
      {:ok, chat} ->
        with {:ok, %ChatMessage{} = msg} <- new_message(chat.id, content, from_id, id_key) do
          publish_chat_message(msg)
          {:ok, msg, chat}
        end

      # If no dialog found, create new dialog and send message
      nil ->
        new_chat_params = %{
          "type" => "dialog",
          "creator_id" => from_id,
          "members" => [
            %{"user_id" => from_id},
            %{"user_id" => to_id}
          ]
        }

        with {:ok, %Chat{} = chat} <- ChatService.create(new_chat_params) do
          with {:ok, %ChatMessage{} = msg} <- new_message(chat.id, content, from_id, id_key) do
            publish_chat_message(msg)
            {:ok, msg, chat}
          end
        end
    end

    # TODO: maybe transaction, maybe constraint on dialog
  end

  def edit(id, content) do
    msg = Chats.get_chat_message!(id)

    change = %{
      content: content,
      edited_at: DateTime.utc_now()
    }

    with {:ok, %ChatMessage{} = msg} <- Chats.update_chat_message(msg, change) do
      publish_chat_message(msg)
      {:ok, msg}
    end
  end

  def soft_delete(id) do
    msg = Chats.get_message!(id)
    change = %{"deleted_at" => DateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(msg, change) do
      publish_chat_message(msg)
      {:ok, chat_message}
    end
  end

  def delete(id) do
    chat_message = Chats.get_message!(id)

    with {:ok, %ChatMessage{}} <- Chats.delete_chat_message(chat_message) do
      {:ok, chat_message}
    end
  end

  def publish_chat_message(%ChatMessage{} = msg) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:chatroom:#{msg.chat_id}", {:msg_update, msg})
  end
end
