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

  def new_message(chat_id, content, sender_id, id_key, opts \\ []) do
    msg_attr = %{
      content: content,
      chat_id: chat_id,
      sender_id: sender_id,
      idempotency_key: id_key,
      via_sms: opts["via_sms"] || false,
      sms_out_state: if(opts["via_sms"], do: :sending, else: nil),
      sms_number: opts["sms_number"],
      reply_to_id: opts["reply_to_id"],
      forwarded_from_id: opts["forwarded_from_id"],
      author_id: opts["author_id"]
    }

    insertResult = Chats.create_chat_message(msg_attr)

    with {:ok, %ChatMessage{} = msg} <- insertResult do
      publish_message_event(msg)
      send_message_to_push_provider(msg)
      if msg.via_sms, do: send_message_to_sms_provider(msg)
      {:ok, msg}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        # Handle idempotency key violation
        with true <- ChatMessage.already_inserted?(changeset),
             %ChatMessage{} = msg <- Chats.get_message_by_id_key!(id_key) do
          {:ok, msg}
        end

      err ->
        err
    end
  end

  def new_dialog_message(from_id, to_id, content, id_key, opts \\ []) do
    # Try to find existing dialog that can be created in time gap
    # If found, send message to this dialog

    case ChatService.find_dialog(from_id, to_id) do
      {:ok, chat} ->
        with {:ok, %ChatMessage{} = msg} <- new_message(chat.id, content, from_id, id_key, opts) do
          {:ok, msg, chat}
        end

      # If no dialog found, create new dialog and send message to it

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
          with {:ok, %ChatMessage{} = msg} <- new_message(chat.id, content, from_id, id_key, opts) do
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
      publish_message_event(msg)
      {:ok, msg}
    end
  end

  def soft_delete(id) do
    msg = Chats.get_message!(id)
    change = %{"deleted_at" => DateTime.utc_now()}

    with {:ok, %ChatMessage{} = chat_message} <- Chats.update_chat_message(msg, change) do
      publish_message_event(msg)
      {:ok, chat_message}
    end
  end

  def delete(id) do
    chat_message = Chats.get_message!(id)

    with {:ok, %ChatMessage{}} <- Chats.delete_chat_message(chat_message) do
      {:ok, chat_message}
    end
  end

  def publish_message_event(%ChatMessage{} = msg) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:#{msg.chat_id}", {:msg_update, msg})
  end

  def send_message_to_sms_provider(%ChatMessage{} = _) do
    # TODO:  Send message to SMS provider
  end

  def send_message_to_push_provider(%ChatMessage{} = _) do
    # TODO:  Send message to Push provider
  end
end
