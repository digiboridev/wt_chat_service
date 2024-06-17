defmodule WTChatWeb.ChatJSON do
  alias WTChat.Chats.Chat

  @doc """
  Renders a list of chats.
  """
  def index(%{chats: chats}) do
    %{data: for(chat <- chats, do: data(chat))}
  end

  def indexFlat(%{chats: chats}) do
    for(chat <- chats, do: data(chat))
  end

  @doc """
  Renders a single chat.
  """
  def show(%{chat: chat}) do
    %{data: data(chat)}
  end

  def showFlat(%{chat: chat}) do
    data(chat)
  end


  defp data(%Chat{} = chat) do
    %{
      id: chat.id,
      type: chat.type,
      name: chat.name,
      creator_id: chat.creator_id,
      created_at: chat.inserted_at,
      updated_at: chat.updated_at,
      deleted_at: chat.deleted_at,
      members: WTChatWeb.ChatMemberJSON.indexFlat(%{chat_members: chat.members})
    }
  end
end
