defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel

  alias WTChat.Chats
  alias WTChat.Chats.Chat

  alias WTChatWeb.ChatJSON
  # alias WTChatWeb.ChatMemberJSON
  alias WTChatWeb.ChatMessageJSON

  alias WTChat.ChatService
  # alias WTChat.ChatMemberService
  alias WTChat.ChatMessageService

  # Service channel that needs to reply user with the user_id that verified in the connect function
  def join("chat:auth", _message, socket) do
    userId = socket.assigns.user_id
    {:ok, %{"user_id" => userId}, socket}
  end

  # Channel for events that related to the specific user
  def join("chat:user:" <> topic_user_id, _message, socket) do
    socket_user_id = socket.assigns.user_id

    cond do
      socket_user_id == topic_user_id ->
        {:ok, socket}

      true ->
        {:error, %{reason: "trying to join a chat that is not yours"}}
    end
  end

  # User event for syncing the chat list fully or since a specific time
  def handle_in("chat_list_get", payload, socket) do
    user_id = socket.assigns.user_id
    since = payload["since"]

    chats =
      case since do
        nil ->
          Chats.list_chats(user_id)

        _ ->
          Chats.list_chats(
            user_id,
            since |> DateTime.from_unix!(:microsecond) |> DateTime.to_iso8601()
          )
      end

    json = %{chats: chats} |> ChatJSON.index()
    {:reply, {:ok, json}, socket}
  end

  # User event for creating a new chat
  def handle_in("chat_create_raw", payload, socket) do
    chat = ChatService.create(payload)

    case chat do
      {:ok, chat} ->
        json = %{chat: chat} |> ChatJSON.showFlat()
        {:reply, {:ok, json}, socket}

      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  # Simplified user event for creating dialog with another user and sending the first message
  def handle_in("new_dialog", payload, socket) do
    user_id = socket.assigns.user_id
    participant = payload["participant"]
    first_message = payload["first_message"]

    # TODO atomic transaction

    chat_params = %{
      "type" => "dialog",
      "creator_id" => user_id,
      "members" => [
        %{"user_id" => user_id},
        %{"user_id" => participant}
      ]
    }

    chat = ChatService.create(%{"chat" => chat_params})

    msg_params = %{
      "chat_id" => chat.id,
      "sender_id" => user_id,
      "content" => first_message
    }

    msg = ChatMessageService.create(msg_params)

    chat_json = %{chat: chat} |> ChatJSON.showFlat()
    msg_json = %{chat_message: msg} |> ChatMessageJSON.showFlat()
    reply_json = %{chat: chat_json, message: msg_json}
    {:reply, {:ok, reply_json}, socket}
  end

  def handle_in(event, _payload, socket) do
    IO.puts(event)
    {:noreply, socket}
  end

  def handle_info({:chat_update, %Chat{} = data}, socket) do
    json = %{chat: data} |> ChatJSON.showFlat()
    push(socket, "chat_update", json)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg)
    {:noreply, socket}
  end
end
