defmodule WTChat.ChatsTest do
  use WTChat.DataCase

  alias WTChat.Chats

  describe "chats" do
    alias WTChat.Chats.Chat

    import WTChat.ChatsFixtures

    @invalid_attrs %{name: nil, type: nil, creator_id: nil, edited_at: nil, deleted_at: nil}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Chats.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Chats.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      valid_attrs = %{name: "some name", type: :dialog, creator_id: "some creator_id", edited_at: ~N[2024-06-11 07:52:00], deleted_at: ~N[2024-06-11 07:52:00]}

      assert {:ok, %Chat{} = chat} = Chats.create_chat(valid_attrs)
      assert chat.name == "some name"
      assert chat.type == :dialog
      assert chat.creator_id == "some creator_id"
      assert chat.edited_at == ~N[2024-06-11 07:52:00]
      assert chat.deleted_at == ~N[2024-06-11 07:52:00]
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{name: "some updated name", type: :group, creator_id: "some updated creator_id", edited_at: ~N[2024-06-12 07:52:00], deleted_at: ~N[2024-06-12 07:52:00]}

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, update_attrs)
      assert chat.name == "some updated name"
      assert chat.type == :group
      assert chat.creator_id == "some updated creator_id"
      assert chat.edited_at == ~N[2024-06-12 07:52:00]
      assert chat.deleted_at == ~N[2024-06-12 07:52:00]
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
      assert chat == Chats.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
