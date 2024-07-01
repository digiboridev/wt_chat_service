defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel

  require Logger

  alias WTChat.Chats
  alias WTChat.Chats.Chat
  alias WTChat.Chats.ChatMessage
  alias WTChatWeb.ChatJSON
  alias WTChatWeb.ChatMessageJSON
  alias WTChat.ChatService
  alias WTChat.ChatMessageService

  @impl true
  def join("chat:auth", _message, socket) do
    userId = socket.assigns.user_id
    {:ok, %{"user_id" => userId}, socket}
  end

  @impl true
  def join("chat:user:" <> topic_user_id, _message, socket) do
    cond do
      socket.assigns.user_id == topic_user_id ->
        {:ok, socket}

      true ->
        {:error, %{reason: "trying to join a chat that is not yours"}}
    end
  end

  def join("chat:" <> chat_id, _, %{assigns: %{user_id: user_id}} = socket) do
    with {:ok, chat} <- ChatService.get_by_id(chat_id) do
      if chat.members |> Enum.find(&(&1.user_id == user_id)) == nil do
        {:error, "You are not a member of the chat"}
      else
        {:ok, chat |> ChatJSON.show_flat(), assign(socket, chat_id: chat_id)}
      end
    else
      _ -> {:error, %{reason: "Unknown chat"}}
    end
  end

  ##
  ## Chat related incoming events start

  @impl true
  def handle_in(
        "chat:create_group",
        %{"name" => name, "member_ids" => member_ids},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    case ChatService.create_group(name, user_id, member_ids) do
      {:ok, chat} -> {:reply, {:ok, chat |> ChatJSON.show_flat()}, socket}
      {:error, _reason} -> {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "chat:create_dialog",
        %{"id_key" => id_key, "first_message_content" => message_content, "recipient" => recipient} = opts,
        %{assigns: %{user_id: user_id}} = socket
      ) do
    case ChatMessageService.new_dialog_message(user_id, recipient, message_content, id_key, opts) do
      {:ok, msg, chat} ->
        {:reply, {:ok, %{msg: msg |> ChatMessageJSON.show_flat(), chat: chat |> ChatJSON.show_flat()}}, socket}

      {:error, _reason} ->
        {:reply, :error, socket}
    end
  end

  @deprecated "No needed anymore"
  def handle_in(
        "chat:list",
        %{"updated_after" => updated_after, "limit" => limit},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    chats = ChatService.chat_updates(user_id, updated_after, limit)

    {:reply, {:ok, %{chats: chats} |> ChatJSON.index()}, socket}
  end

  @deprecated "No needed anymore"
  @impl true
  def handle_in("chat:list", _payload, %{assigns: %{user_id: user_id}} = socket) do
    chats = ChatService.chat_list(user_id)

    {:reply, {:ok, %{chats: chats} |> ChatJSON.index()}, socket}
  end

  @impl true
  def handle_in("chat:user_chat_ids", _payload, %{assigns: %{user_id: user_id}} = socket) do
    ids = ChatService.get_user_chat_ids(user_id)
    {:reply, {:ok, ids}, socket}
  end

  def handle_in(
        "chat:add_member",
        %{"member_id" => member_id},
        %{assigns: %{chat_id: chat_id, user_id: user_id}} = socket
      ) do
    case ChatService.add_member(chat_id, member_id, user_id) do
      {:ok, chat} -> {:reply, {:ok, chat |> ChatJSON.show_flat()}, socket}
      {:error, reason} -> {:reply, {:error, "#{reason}"}, socket}
    end
  end

  @impl true
  def handle_in(
        "chat:leave",
        %{},
        %{assigns: %{chat_id: chat_id, user_id: user_id}} = socket
      ) do
    case ChatService.leave_chat(chat_id, user_id) do
      {:ok, chat} -> {:reply, {:ok, chat |> ChatJSON.show_flat()}, socket}
      {:error, reason} -> {:reply, {:error, "#{reason}"}, socket}
    end
  end

  @impl true
  def handle_in(
        "chat:block_member",
        %{"member_id" => member_id},
        %{assigns: %{chat_id: chat_id, user_id: user_id}} = socket
      ) do
    case ChatService.block_member(chat_id, member_id, user_id) do
      {:ok, chat} -> {:reply, {:ok, chat |> ChatJSON.show_flat()}, socket}
      {:error, reason} -> {:reply, {:error, "#{reason}"}, socket}
    end
  end

  ## Chat related incoming events end
  ##

  ##
  # Message related incoming events start

  @impl true
  def handle_in(
        "message:new",
        %{"id_key" => id_key, "content" => content} = opts,
        %{assigns: %{user_id: user_id, chat_id: chat_id}} = socket
      ) do
    case ChatMessageService.new_message(chat_id, content, user_id, id_key, opts) do
      {:ok, msg} -> {:reply, {:ok, msg |> ChatMessageJSON.show_flat()}, socket}
      {:error, _reason} -> {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "message:updates",
        %{"updated_after" => updated_after, "limit" => limit},
        %{assigns: %{chat_id: chat_id}} = socket
      ) do
    messages = ChatMessageService.message_updates(chat_id, updated_after, limit)

    {:reply, {:ok, %{chat_messages: messages} |> ChatMessageJSON.index()}, socket}
  end

  @impl true
  def handle_in(
        "message:history",
        %{"limit" => limit} = payload,
        %{assigns: %{chat_id: chat_id}} = socket
      ) do
    created_before = Map.get(payload, "created_before")
    messages = ChatMessageService.message_history(chat_id, created_before, limit)

    {:reply, {:ok, %{chat_messages: messages} |> ChatMessageJSON.index()}, socket}
  end

  @impl true
  def handle_in(
        "message:mark_as_viewed",
        %{"message_ids" => message_ids} = payload,
        %{assigns: %{user_id: user_id}} = socket
      ) do
    viewed_at = DateTime.utc_now()

    Chats.mark_messages_as_viewed(message_ids, viewed_at)
    broadcast_from(socket, "messages_viewed", %{payload | "user_id" => user_id, "viewed_at" => viewed_at})

    {:noreply, socket}
  end

  @impl true
  def handle_in("user:typing", payload, %{assigns: %{user_id: user_id}} = socket) do
    broadcast_from(socket, "typing", %{payload | "user_id" => user_id})

    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    Logger.warning("Handle unexpected handle_in/3 event: #{event}. Payload: #{inspect(payload)}")

    {:noreply, socket}
  end

  ## Message related incoming events end
  ##

  ##
  ## Outgoing events start

  @deprecated "No needed"
  def handle_info({:chat_update, %Chat{} = chat}, socket) do
    push(socket, "chat_update", chat |> ChatJSON.show_flat())

    {:noreply, socket}
  end

  @impl true
  def handle_info({:chat_info_update, %Chat{} = chat}, socket) do
    push(socket, "chat_info_update", chat |> ChatJSON.show_flat())

    {:noreply, socket}
  end

  @impl true
  def handle_info({:chat_membership_join, chat_id}, socket) do
    push(socket, "chat_membership_update", chat_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:chat_membership_leave, chat_id}, socket) do
    push(socket, "chat_membership_update", chat_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:msg_update, %ChatMessage{} = message}, socket) do
    push(socket, "message_update", message |> ChatMessageJSON.show_flat())

    {:noreply, socket}
  end

  @impl true
  def handle_info(message, socket) do
    Logger.warning("Handle unexpected handle_info/2 message: #{message}")

    {:noreply, socket}
  end

  ## Outgoing events end
  ##
end
