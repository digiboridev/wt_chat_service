defmodule WTChat.ChatMessageService do
  alias WTChat.Chats
  alias WTChat.Chats.ChatMessage
  # alias WTChat.Chats.Chat

  def message_history(params) do
    chat_id = Map.get(params, "chat_id")
    from = Map.get(params, "from")
    limit = Map.get(params, "limit", 200)

    case {chat_id, from} do
      {nil, nil} -> Chats.message_history()
      {chat_id, nil} -> Chats.message_history(chat_id, limit)
      {chat_id, from} -> Chats.message_history(chat_id, from, limit)
    end
  end

  def message_updates(params) do
    chat_id = Map.get(params, "chat_id")
    from = Map.get(params, "from")
    limit = Map.get(params, "limit", 200)

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

  def new_dialog_message(from_id, to_id, id_key) do
    IO.inspect(from_id)
    IO.inspect(to_id)
    IO.inspect(id_key)
    # TODO find dialog or create
    # TODO new msg
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

  def publish_dialog_message(%ChatMessage{} = msg, user1, user2) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:dialog:#{user1},#{user2}", {:msg_update, msg})
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:dialog:#{user2},#{user1}", {:msg_update, msg})
  end
end
