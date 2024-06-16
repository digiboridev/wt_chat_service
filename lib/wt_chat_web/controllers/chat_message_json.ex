defmodule WTChatWeb.ChatMessageJSON do
  alias WTChat.Chats.ChatMessage

  @doc """
  Renders a list of chat_messages.
  """
  def index(%{chat_messages: chat_messages}) do
    %{data: for(chat_message <- chat_messages, do: data(chat_message))}
  end

  def indexFlat(%{chat_messages: chat_messages}) do
    for(chat_message <- chat_messages, do: data(chat_message))
  end

  @doc """
  Renders a single chat_message.
  """
  def show(%{chat_message: chat_message}) do
    %{data: data(chat_message)}
  end

  def showFlat(%{chat_message: chat_message}) do
    data(chat_message)
  end

  defp data(%ChatMessage{} = chat_message) do
    %{
      id: chat_message.id,
      sender_id: chat_message.sender_id,
      chat_id: chat_message.chat_id,
      reply_to_id: chat_message.reply_to_id,
      forwarded_from_id: chat_message.forwarded_from_id,
      author_id: chat_message.author_id,
      via_sms: chat_message.via_sms,
      sms_out_state: chat_message.sms_out_state,
      sms_number: chat_message.sms_number,
      content: chat_message.content,
      idempotency_key: chat_message.idempotency_key,
      edited_at: chat_message.edited_at,
      created_at: chat_message.created_at,
      updated_at: chat_message.updated_at,
      deleted_at: chat_message.deleted_at
    }
  end
end
