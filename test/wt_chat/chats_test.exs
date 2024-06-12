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

  describe "chat_messages" do
    alias WTChat.Chats.ChatMessage

    import WTChat.ChatsFixtures

    @invalid_attrs %{sender_id: nil, reply_to_id: nil}

    test "list_chat_messages/0 returns all chat_messages" do
      chat_message = chat_message_fixture()
      assert Chats.list_chat_messages() == [chat_message]
    end

    test "get_chat_message!/1 returns the chat_message with given id" do
      chat_message = chat_message_fixture()
      assert Chats.get_chat_message!(chat_message.id) == chat_message
    end

    test "create_chat_message/1 with valid data creates a chat_message" do
      valid_attrs = %{sender_id: "some sender_id", reply_to_id: "some reply_to_id"}

      assert {:ok, %ChatMessage{} = chat_message} = Chats.create_chat_message(valid_attrs)
      assert chat_message.sender_id == "some sender_id"
      assert chat_message.reply_to_id == "some reply_to_id"
    end

    test "create_chat_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_message(@invalid_attrs)
    end

    test "update_chat_message/2 with valid data updates the chat_message" do
      chat_message = chat_message_fixture()
      update_attrs = %{sender_id: "some updated sender_id", reply_to_id: "some updated reply_to_id"}

      assert {:ok, %ChatMessage{} = chat_message} = Chats.update_chat_message(chat_message, update_attrs)
      assert chat_message.sender_id == "some updated sender_id"
      assert chat_message.reply_to_id == "some updated reply_to_id"
    end

    test "update_chat_message/2 with invalid data returns error changeset" do
      chat_message = chat_message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_message(chat_message, @invalid_attrs)
      assert chat_message == Chats.get_chat_message!(chat_message.id)
    end

    test "delete_chat_message/1 deletes the chat_message" do
      chat_message = chat_message_fixture()
      assert {:ok, %ChatMessage{}} = Chats.delete_chat_message(chat_message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_message!(chat_message.id) end
    end

    test "change_chat_message/1 returns a chat_message changeset" do
      chat_message = chat_message_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_message(chat_message)
    end
  end

  describe "chat_messages" do
    alias WTChat.Chats.ChatMessage

    import WTChat.ChatsFixtures

    @invalid_attrs %{sender_id: nil, reply_to_id: nil, author_id: nil, via_sms: nil, sms_out_state: nil, sms_number: nil, content: nil, edited_at: nil, deleted_at: nil}

    test "list_chat_messages/0 returns all chat_messages" do
      chat_message = chat_message_fixture()
      assert Chats.list_chat_messages() == [chat_message]
    end

    test "get_chat_message!/1 returns the chat_message with given id" do
      chat_message = chat_message_fixture()
      assert Chats.get_chat_message!(chat_message.id) == chat_message
    end

    test "create_chat_message/1 with valid data creates a chat_message" do
      valid_attrs = %{sender_id: "some sender_id", reply_to_id: "some reply_to_id", author_id: "some author_id", via_sms: true, sms_out_state: :sending, sms_number: "some sms_number", content: "some content", edited_at: ~N[2024-06-11 11:46:00], deleted_at: ~N[2024-06-11 11:46:00]}

      assert {:ok, %ChatMessage{} = chat_message} = Chats.create_chat_message(valid_attrs)
      assert chat_message.sender_id == "some sender_id"
      assert chat_message.reply_to_id == "some reply_to_id"
      assert chat_message.author_id == "some author_id"
      assert chat_message.via_sms == true
      assert chat_message.sms_out_state == :sending
      assert chat_message.sms_number == "some sms_number"
      assert chat_message.content == "some content"
      assert chat_message.edited_at == ~N[2024-06-11 11:46:00]
      assert chat_message.deleted_at == ~N[2024-06-11 11:46:00]
    end

    test "create_chat_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_message(@invalid_attrs)
    end

    test "update_chat_message/2 with valid data updates the chat_message" do
      chat_message = chat_message_fixture()
      update_attrs = %{sender_id: "some updated sender_id", reply_to_id: "some updated reply_to_id", author_id: "some updated author_id", via_sms: false, sms_out_state: :error, sms_number: "some updated sms_number", content: "some updated content", edited_at: ~N[2024-06-12 11:46:00], deleted_at: ~N[2024-06-12 11:46:00]}

      assert {:ok, %ChatMessage{} = chat_message} = Chats.update_chat_message(chat_message, update_attrs)
      assert chat_message.sender_id == "some updated sender_id"
      assert chat_message.reply_to_id == "some updated reply_to_id"
      assert chat_message.author_id == "some updated author_id"
      assert chat_message.via_sms == false
      assert chat_message.sms_out_state == :error
      assert chat_message.sms_number == "some updated sms_number"
      assert chat_message.content == "some updated content"
      assert chat_message.edited_at == ~N[2024-06-12 11:46:00]
      assert chat_message.deleted_at == ~N[2024-06-12 11:46:00]
    end

    test "update_chat_message/2 with invalid data returns error changeset" do
      chat_message = chat_message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_message(chat_message, @invalid_attrs)
      assert chat_message == Chats.get_chat_message!(chat_message.id)
    end

    test "delete_chat_message/1 deletes the chat_message" do
      chat_message = chat_message_fixture()
      assert {:ok, %ChatMessage{}} = Chats.delete_chat_message(chat_message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_message!(chat_message.id) end
    end

    test "change_chat_message/1 returns a chat_message changeset" do
      chat_message = chat_message_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_message(chat_message)
    end
  end
end
