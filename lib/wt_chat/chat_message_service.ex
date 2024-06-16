defmodule WTChat.ChatMessageService do
  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage
  alias WTChat.Chats.Chat

  def message_history(params) do
    chat_id_filter = Map.get(params, "chat_id")
    from = Map.get(params, "from")
    limit = Map.get(params, "limit", 200)

    case {chat_id_filter, from} do
      {nil, nil} -> Chats.message_history()
      {chat_id_filter, nil} -> Chats.message_history(chat_id_filter, limit)
      {chat_id_filter, from} -> Chats.message_history(chat_id_filter, from, limit)
    end
  end

  def message_updates(params) do
    chat_id = Map.get(params, "chat_id")
    from = Map.get(params, "from")
    limit = Map.get(params, "limit", 200)

    case {chat_id, from} do
      {nil, nil} -> {:error, "from required"}
      {from, nil} -> Chats.message_updates(from, limit)
      {from, chat_id} -> Chats.message_updates( from, limit,chat_id)
    end
  end

  def new_message(chat_id, content, sender_id, id_key) do
    chat = Chats.get_chat_with_members!(chat_id)
    time = DateTime.utc_now()
    content_preview = String.slice(content, 0, 20)

    msg_attr = %{
      content: content,
      chat_id: chat_id,
      sender_id: sender_id,
      created_at: time,
      idempotency_key: id_key
    }

    chat_attr = %{
      id: chat.id,
      last_msg_preview: content_preview,
      last_msg_at: time,
      last_msg_sender_id: sender_id,
      message_count: chat.message_count + 1
    }

    with {:ok, %ChatMessage{} = msg, %Chat{} = chat} <-
           Chats.new_chat_message(msg_attr, chat, chat_attr) do
      publish_chat_message(msg, chat)
      {:ok, msg}
    end
  end

  def edit(id, content) do
    chat_message = Chats.get_chat_message!(id)

    chat_message_params = %{
      content: content,
      edited_at: DateTime.utc_now()
    }

    with {:ok, %ChatMessage{} = chat_message} <-
           Chats.update_chat_message(chat_message, chat_message_params) do
      chat = chat_message.chat
      chat |> IO.inspect()
      {:ok, chat_message}
    end
  end

  def soft_delete(id) do
    chat_message = Chats.get_message!(id)
    chat_message_params = %{"deleted_at" => DateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <-
           Chats.update_chat_message(chat_message, chat_message_params) do
      {:ok, chat_message}
    end
  end

  def delete(id) do
    chat_message = Chats.get_message!(id)

    with {:ok, %ChatMessage{}} <- Chats.delete_chat_message(chat_message) do
      {:ok, chat_message}
    end
  end

  def publish_chat_message(%ChatMessage{} = msg, %Chat{} = chat) do
    Enum.each(chat.members, fn member ->
      Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:user:#{member.user_id}", {:chat_update, chat})
    end)

    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:chatroom:#{chat.id}", {:msg_update, msg})
  end

  def publish_dialog_message(%ChatMessage{} = msg, user1, user2) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:dialog:#{user1},#{user2}", {:msg_update, msg})
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:dialog:#{user2},#{user1}", {:msg_update, msg})
  end
end
