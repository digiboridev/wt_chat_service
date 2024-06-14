
defmodule WTChat.ChatService do
  alias WTChat.Chats
  alias WTChat.Chats.Chat


  def index(params) do
    member_filter = Map.get(params, "member_id")
    updated_at_filter = Map.get(params, "updated_at")

    case {member_filter, updated_at_filter} do
      {nil, nil} -> Chats.list_chats()
      {member_id, nil} -> Chats.list_chats(member_id)
      {member_id, updated_at} -> Chats.list_chats(member_id, updated_at)
    end
  end

  def create(%{"chat" => chat_params}) do
    # append joined_at to each member
    chat_params =
      Map.put(chat_params, "members", append_members_join_date(chat_params["members"]))

    with {:ok, %Chat{} = chat} <- Chats.create_chat(chat_params) do
      publish_chat_update(%Chat{} = chat)
      {:ok, chat}
    end
  end

  def show(%{"id" => id}) do
    with chat <- Chats.get_chat!(id) do
      {:ok, chat}
    end
  end

  def update(%{"id" => id, "chat" => chat_params}) do
    chat = Chats.get_chat!(id)

    # append joined_at to each new member
    chat_params =
      Map.put(chat_params, "members", append_members_join_date(chat_params["members"]))

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params) do
      publish_chat_update(chat)
      {:ok, chat}
    end
  end

  def soft_delete(%{"id" => id}) do
    chat = Chats.get_chat!(id)
    chat_params = %{"deleted_at" => NaiveDateTime.utc_now()}

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params) do
      publish_chat_update(chat)
      {:ok, chat}
    end
  end

  def delete(%{"id" => id}) do
    chat = Chats.get_chat!(id)

    with {:ok, %Chat{}} <- Chats.delete_chat(chat) do
      {:ok, chat}
    end
  end

  def append_members_join_date(members) do
    Enum.map(members, fn member ->
      case member["joined_at"] do
        nil -> Map.put(member, "joined_at", DateTime.utc_now())
        _ -> member
      end
    end)
  end

  def publish_chat_update(%Chat{} = chat) do
    # Notify all chat members about the chat update event
    chat_members = chat.members

    Enum.each(chat_members, fn member ->
      Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:user:#{member.user_id}", {:chat_update, chat})
    end)
  end
end
