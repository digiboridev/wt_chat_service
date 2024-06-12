defmodule WTChat.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WTChat.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        creator_id: "some creator_id",
        deleted_at: ~N[2024-06-11 07:52:00],
        edited_at: ~N[2024-06-11 07:52:00],
        name: "some name",
        type: :dialog
      })
      |> WTChat.Chats.create_chat()

    chat
  end



  @doc """
  Generate a chat_member.
  """
  def chat_member_fixture(attrs \\ %{}) do
    {:ok, chat_member} =
      attrs
      |> Enum.into(%{
        blocked_at: ~N[2024-06-11 08:56:00],
        joined_at: ~N[2024-06-11 08:56:00],
        left_at: ~N[2024-06-11 08:56:00],
        user_id: "some user_id"
      })
      |> WTChat.Chats.create_chat_member()

    chat_member
  end

  @doc """
  Generate a chat_message.
  """
  def chat_message_fixture(attrs \\ %{}) do
    {:ok, chat_message} =
      attrs
      |> Enum.into(%{
        author_id: "some author_id",
        content: "some content",
        deleted_at: ~N[2024-06-11 11:46:00],
        edited_at: ~N[2024-06-11 11:46:00],
        reply_to_id: "some reply_to_id",
        sender_id: "some sender_id",
        sms_number: "some sms_number",
        sms_out_state: :sending,
        via_sms: true
      })
      |> WTChat.Chats.create_chat_message()

    chat_message
  end
end
