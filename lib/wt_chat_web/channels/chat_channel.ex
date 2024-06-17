defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel

  alias WTChat.Chats.Chat
  alias WTChat.Chats.ChatMessage

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

  # Channel for events that related to the specific chat
  def join("chat:chatroom:" <> chat_id, _, socket) do
    IO.puts("chatroom join")
    IO.puts("chat_id: #{chat_id}")
    {:ok, socket}
  end

  # Fall back channel for chat-less dialog
  # Uses only for wait on first message with newly created chat id for reconnect to the chatroom
  def join("chat:dialog:" <> users, _params, socket) do
    from_user = hd(String.split(users, ","))
    to_user = hd(tl(String.split(users, ",")))
    IO.puts("dialog join")
    IO.puts("from_user: #{from_user}")
    IO.puts("to_user: #{to_user}")

    case ChatService.find_dialog(from_user, to_user) do
      {:ok, chat} -> {:ok, %{"chat_id" => chat.id}, socket}
      nil -> {:ok, socket}
    end
  end

  # User event for getting the actual chat list
  def handle_in("chat_list_get", _payload, socket) do
    user_id = socket.assigns.user_id
    chats = ChatService.chat_list(%{member_id: user_id})

    json = %{chats: chats} |> ChatJSON.index()
    {:reply, {:ok, json}, socket}
  end

  # User event for syncing chat list updates from a specific time
  def handle_in("chat_list_updates", payload, socket) do
    user_id = socket.assigns.user_id
    updates_from = payload["updates_from"]
    limit = payload["limit"]

    chats =
      ChatService.chat_updates(%{
        member_id: user_id,
        from: updates_from |> DateTime.from_unix!(:microsecond) |> DateTime.to_iso8601(),
        limit: limit
      })

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

  def handle_in("new_msg", payload, socket) do
    user_id = socket.assigns.user_id

    chat_id = payload["chat_id"]
    content = payload["content"]
    id_key = payload["id_key"]

    case ChatMessageService.new_message(chat_id, content, user_id, id_key) do
      {:ok, msg} ->
        json = %{chat_message: msg} |> ChatMessageJSON.showFlat()
        {:reply, {:ok, json}, socket}

      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("new_dialog_msg", payload, socket) do
    user_id = socket.assigns.user_id

    to_id = payload["to_id"]
    content = payload["content"]
    id_key = payload["id_key"]

    with {:ok, msg} <- ChatMessageService.new_dialog_message(user_id, to_id, content, id_key) do
      json = %{chat_message: msg} |> ChatMessageJSON.showFlat()
      {:reply, {:ok, json}, socket}
    else
      {:error, reason} -> {:reply, {:error, reason}, socket}
    end
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

  def handle_info({:msg_update, %ChatMessage{} = message}, socket) do
    json = %{chat_message: message} |> ChatMessageJSON.showFlat()
    push(socket, "message_update", json)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg)
    {:noreply, socket}
  end
end
