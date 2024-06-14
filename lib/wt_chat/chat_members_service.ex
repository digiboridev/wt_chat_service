
defmodule WTChat.ChatMemberService do
  alias WTChat.Chats

  def index() do
    Chats.list_chat_members()
  end


  def index_by_chat_id(chat_id) do
    chat_id |> Chats.list_chat_members_by_chat_id
  end
end
