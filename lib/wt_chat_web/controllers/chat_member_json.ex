defmodule WTChatWeb.ChatMemberJSON do
  alias WTChat.Chats.ChatMember

  @doc """
  Renders a list of chat_members.
  """
  def index(%{chat_members: chat_members}) do
    %{data: for(chat_member <- chat_members, do: data(chat_member))}
  end

  def indexFlat(%{chat_members: chat_members}) do
    for(chat_member <- chat_members, do: data(chat_member))
  end

  @doc """
  Renders a single chat_member.
  """
  def show(%{chat_member: chat_member}) do
    %{data: data(chat_member)}
  end

  defp data(%ChatMember{} = chat_member) do
    %{
      id: chat_member.id,
      chat_id: chat_member.chat_id,
      user_id: chat_member.user_id,
      joined_at: chat_member.joined_at,
      left_at: chat_member.left_at,
      blocked_at: chat_member.blocked_at
    }
  end
end
