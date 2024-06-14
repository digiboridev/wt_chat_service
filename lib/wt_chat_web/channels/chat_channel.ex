defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel

  alias WTChat.Chats
  alias WTChat.Chats.Chat
  alias WTChatWeb.ChatJSON

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

  def handle_in("chat_create", payload, socket) do
    chat = WtChatWeb.ChatService.create(payload)

    case chat do
      {:ok, chat} ->
        json = %{chat: chat} |> ChatJSON.showFlat()
        {:reply, {:ok, json}, socket}

      {:error, reason} ->
        {:reply, {:error, reason}, socket}
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

  def handle_info(msg, socket) do
    IO.inspect(msg)
    {:noreply, socket}
  end
end
