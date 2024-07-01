defmodule WTChat.ChatService do
  # alias WTChat.Chats.ChatMember
  alias WTChat.Chats
  alias WTChat.Chats.Chat

  def chat_list(member_id) do
    case member_id do
      nil -> Chats.chat_list()
      _ -> Chats.chat_list(member_id)
    end
  end

  @deprecated "Use raw lists instead"
  def chat_updates(member_id, from, limit) do
    case {from, member_id} do
      {nil, nil} -> {:error, "from date required"}
      {from, nil} -> Chats.chat_updates(from, limit)
      {from, member_id} -> Chats.chat_updates(from, limit, member_id)
    end
  end

  def create(chat_params) do
    member_ids = chat_params["members"] |> Enum.map(& &1["user_id"])
    chat_params = Map.put(chat_params, "members", append_members_join_date(member_ids))

    with {:ok, %Chat{} = chat} <- Chats.create_chat(chat_params),
         _ <- publish_chat_update(%Chat{} = chat),
         _ <-
           Enum.each(member_ids, fn member_id ->
             publish_chat_membership_update(chat, member_id)
           end) do
      {:ok, chat}
    end
  end

  def create_group(name, creator_id, members_ids) do
    members_ids = Enum.uniq([creator_id | members_ids])

    chat_params = %{
      name: name,
      type: :group,
      creator_id: creator_id,
      members:
        Enum.map(members_ids, fn member_id ->
          %{user_id: member_id, joined_at: DateTime.utc_now()}
        end)
    }

    with {:ok, %Chat{} = chat} <- Chats.create_chat(chat_params),
         _ <- publish_chat_update(%Chat{} = chat),
         _ <-
           Enum.each(members_ids, fn member_id ->
             publish_chat_membership_update(chat, member_id)
           end) do
      {:ok, chat}
    end
  end

  def show(chat_id) do
    with chat <- Chats.get_chat_with_members!(chat_id) do
      {:ok, chat}
    end
  end

  def update(chat_id, chat_params) do
    chat = Chats.get_chat!(chat_id)
    chat_params = Map.drop(chat_params, ["creator_id", "members", "messages"])

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_params),
         _ <- publish_chat_update(chat),
         _ <- publish_chat_info_update(chat) do
      {:ok, chat}
    end
  end

  def add_member(chat_id, member_id, user_id) do
    chat = Chats.get_chat_with_members!(chat_id)

    if member_id == user_id do
      {:error, "You can't add yourself to the chat"}
    end

    if chat.creator_id != user_id do
      {:error, "You can't add members to the chat"}
    end

    member_params = %{joined_at: DateTime.utc_now(), chat_id: chat_id, user_id: member_id}
    chat_changes = %{updated_at: DateTime.utc_now()}

    with {:ok, %Chat{} = chat} <- Chats.add_chat_member(chat, chat_changes, member_params),
         _ <- publish_chat_update(chat),
         _ <- publish_chat_membership_update(chat, member_id),
         _ <- publish_chat_info_update(chat) do
      {:ok, chat}
    end
  end

  def leave_chat(chat_id, user_id) do
    chat = Chats.get_chat_with_members!(chat_id)

    if chat.members |> Enum.find(&(&1.user_id == user_id)) == nil do
      {:error, "You are not a member of the chat"}
    end

    member_changes = %{left_at: DateTime.utc_now()}
    chat_changes = %{updated_at: DateTime.utc_now()}

    with {:ok, %Chat{} = chat} <-
           Chats.update_chat_with_member(chat, chat_changes, user_id, member_changes),
         _ <- publish_chat_update(chat),
         _ <- publish_chat_membership_update(chat, user_id),
         _ <- publish_chat_info_update(chat) do
      {:ok, chat}
    end
  end

  def block_member(chat_id, member_id, user_id) do
    chat = Chats.get_chat_with_members!(chat_id)

    if chat.creator_id != user_id do
      {:error, "You can't block members to the chat"}
    end

    if chat.members |> Enum.find(&(&1.user_id == member_id)) == nil do
      {:error, "You are not a member of the chat"}
    end

    member_changes = %{blocked_at: DateTime.utc_now()}
    chat_changes = %{updated_at: DateTime.utc_now()}

    # TODO: validate that member is in chat and the actor is the chat creator/owner

    with {:ok, %Chat{} = chat} <-
           Chats.update_chat_with_member(chat, chat_changes, member_id, member_changes),
         _ <- publish_chat_update(chat),
         _ <- publish_chat_membership_update(chat, member_id),
         _ <- publish_chat_info_update(chat) do
      {:ok, chat}
    end
  end

  def find_dialog(from_user, to_user) do
    result = Chats.find_dialog(from_user, to_user)

    case result do
      %Chat{} -> {:ok, result}
      nil -> nil
    end
  end

  def soft_delete(chat_id) do
    chat = Chats.get_chat!(chat_id)
    chat_changes = %{"deleted_at" => DateTime.utc_now()}

    with {:ok, %Chat{} = chat} <- Chats.update_chat(chat, chat_changes) do
      publish_chat_update(chat)
      publish_chat_info_update(chat)
      {:ok, chat}
    end
  end

  def delete(chat_id) do
    chat = Chats.get_chat!(chat_id)

    with {:ok, %Chat{}} <- Chats.delete_chat(chat) do
      {:ok, chat}
    end
  end

  defp append_members_join_date(members) do
    Enum.map(members, fn member ->
      case member["joined_at"] do
        nil -> Map.put(member, "joined_at", DateTime.utc_now())
        _ -> member
      end
    end)
  end

  @deprecated "Use separate functions for each event"
  def publish_chat_update(%Chat{} = chat) do
    # Notify all chat members about the chat update event
    chat_members = chat.members

    Enum.each(chat_members, fn member ->
      Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:user:#{member.user_id}", {:chat_update, chat})
    end)
  end

  # Publish realtime event to chatroom topic for notify about chat info update
  defp publish_chat_info_update(%Chat{} = chat) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:#{chat.id}", {:chat_info_update, chat})
  end

  # Publish realtime event to user topic for notify about his chat memberships update
  defp publish_chat_membership_update(%Chat{} = chat, user_id) do
    Phoenix.PubSub.broadcast(WTChat.PubSub, "chat:user:#{user_id}", {:chat_memberships_update, chat})
  end
end
