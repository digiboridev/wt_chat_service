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
end
