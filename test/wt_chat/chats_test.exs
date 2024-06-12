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

  describe "chat_members" do
    alias WTChat.Chats.ChatMember

    import WTChat.ChatsFixtures

    @invalid_attrs %{user_id: nil, joined_at: nil}

    test "list_chat_members/0 returns all chat_members" do
      chat_member = chat_member_fixture()
      assert Chats.list_chat_members() == [chat_member]
    end

    test "get_chat_member!/1 returns the chat_member with given id" do
      chat_member = chat_member_fixture()
      assert Chats.get_chat_member!(chat_member.id) == chat_member
    end

    test "create_chat_member/1 with valid data creates a chat_member" do
      valid_attrs = %{user_id: "some user_id", joined_at: ~N[2024-06-11 08:54:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.create_chat_member(valid_attrs)
      assert chat_member.user_id == "some user_id"
      assert chat_member.joined_at == ~N[2024-06-11 08:54:00]
    end

    test "create_chat_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_member(@invalid_attrs)
    end

    test "update_chat_member/2 with valid data updates the chat_member" do
      chat_member = chat_member_fixture()
      update_attrs = %{user_id: "some updated user_id", joined_at: ~N[2024-06-12 08:54:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.update_chat_member(chat_member, update_attrs)
      assert chat_member.user_id == "some updated user_id"
      assert chat_member.joined_at == ~N[2024-06-12 08:54:00]
    end

    test "update_chat_member/2 with invalid data returns error changeset" do
      chat_member = chat_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_member(chat_member, @invalid_attrs)
      assert chat_member == Chats.get_chat_member!(chat_member.id)
    end

    test "delete_chat_member/1 deletes the chat_member" do
      chat_member = chat_member_fixture()
      assert {:ok, %ChatMember{}} = Chats.delete_chat_member(chat_member)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_member!(chat_member.id) end
    end

    test "change_chat_member/1 returns a chat_member changeset" do
      chat_member = chat_member_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_member(chat_member)
    end
  end

  describe "chat_members" do
    alias WTChat.Chats.ChatMember

    import WTChat.ChatsFixtures

    @invalid_attrs %{user_id: nil, joined_at: nil, left_at: nil}

    test "list_chat_members/0 returns all chat_members" do
      chat_member = chat_member_fixture()
      assert Chats.list_chat_members() == [chat_member]
    end

    test "get_chat_member!/1 returns the chat_member with given id" do
      chat_member = chat_member_fixture()
      assert Chats.get_chat_member!(chat_member.id) == chat_member
    end

    test "create_chat_member/1 with valid data creates a chat_member" do
      valid_attrs = %{user_id: "some user_id", joined_at: ~N[2024-06-11 08:55:00], left_at: ~N[2024-06-11 08:55:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.create_chat_member(valid_attrs)
      assert chat_member.user_id == "some user_id"
      assert chat_member.joined_at == ~N[2024-06-11 08:55:00]
      assert chat_member.left_at == ~N[2024-06-11 08:55:00]
    end

    test "create_chat_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_member(@invalid_attrs)
    end

    test "update_chat_member/2 with valid data updates the chat_member" do
      chat_member = chat_member_fixture()
      update_attrs = %{user_id: "some updated user_id", joined_at: ~N[2024-06-12 08:55:00], left_at: ~N[2024-06-12 08:55:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.update_chat_member(chat_member, update_attrs)
      assert chat_member.user_id == "some updated user_id"
      assert chat_member.joined_at == ~N[2024-06-12 08:55:00]
      assert chat_member.left_at == ~N[2024-06-12 08:55:00]
    end

    test "update_chat_member/2 with invalid data returns error changeset" do
      chat_member = chat_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_member(chat_member, @invalid_attrs)
      assert chat_member == Chats.get_chat_member!(chat_member.id)
    end

    test "delete_chat_member/1 deletes the chat_member" do
      chat_member = chat_member_fixture()
      assert {:ok, %ChatMember{}} = Chats.delete_chat_member(chat_member)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_member!(chat_member.id) end
    end

    test "change_chat_member/1 returns a chat_member changeset" do
      chat_member = chat_member_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_member(chat_member)
    end
  end

  describe "chat_members" do
    alias WTChat.Chats.ChatMember

    import WTChat.ChatsFixtures

    @invalid_attrs %{user_id: nil, joined_at: nil, left_at: nil, blocked_at: nil}

    test "list_chat_members/0 returns all chat_members" do
      chat_member = chat_member_fixture()
      assert Chats.list_chat_members() == [chat_member]
    end

    test "get_chat_member!/1 returns the chat_member with given id" do
      chat_member = chat_member_fixture()
      assert Chats.get_chat_member!(chat_member.id) == chat_member
    end

    test "create_chat_member/1 with valid data creates a chat_member" do
      valid_attrs = %{user_id: "some user_id", joined_at: ~N[2024-06-11 08:56:00], left_at: ~N[2024-06-11 08:56:00], blocked_at: ~N[2024-06-11 08:56:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.create_chat_member(valid_attrs)
      assert chat_member.user_id == "some user_id"
      assert chat_member.joined_at == ~N[2024-06-11 08:56:00]
      assert chat_member.left_at == ~N[2024-06-11 08:56:00]
      assert chat_member.blocked_at == ~N[2024-06-11 08:56:00]
    end

    test "create_chat_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_member(@invalid_attrs)
    end

    test "update_chat_member/2 with valid data updates the chat_member" do
      chat_member = chat_member_fixture()
      update_attrs = %{user_id: "some updated user_id", joined_at: ~N[2024-06-12 08:56:00], left_at: ~N[2024-06-12 08:56:00], blocked_at: ~N[2024-06-12 08:56:00]}

      assert {:ok, %ChatMember{} = chat_member} = Chats.update_chat_member(chat_member, update_attrs)
      assert chat_member.user_id == "some updated user_id"
      assert chat_member.joined_at == ~N[2024-06-12 08:56:00]
      assert chat_member.left_at == ~N[2024-06-12 08:56:00]
      assert chat_member.blocked_at == ~N[2024-06-12 08:56:00]
    end

    test "update_chat_member/2 with invalid data returns error changeset" do
      chat_member = chat_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_member(chat_member, @invalid_attrs)
      assert chat_member == Chats.get_chat_member!(chat_member.id)
    end

    test "delete_chat_member/1 deletes the chat_member" do
      chat_member = chat_member_fixture()
      assert {:ok, %ChatMember{}} = Chats.delete_chat_member(chat_member)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_member!(chat_member.id) end
    end

    test "change_chat_member/1 returns a chat_member changeset" do
      chat_member = chat_member_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_member(chat_member)
    end
  end
end
