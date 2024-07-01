defmodule WTChat.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias WTChat.Repo

  alias WTChat.Chats.Chat
  alias WTChat.Chats.ChatMember
  alias WTChat.Chats.ChatMessage

  def chat_list() do
    query =
      from c in Chat,
        where: is_nil(c.deleted_at),
        order_by: [desc: c.inserted_at],
        select: c

    Repo.all(query) |> Repo.preload(:members)
  end

  def chat_list(member_id) do
    query =
      from c in Chat,
        join: cm in ChatMember,
        on: c.id == cm.chat_id,
        where: cm.user_id == ^member_id and is_nil(c.deleted_at) and is_nil(cm.blocked_at) and is_nil(cm.left_at),
        order_by: [desc: c.inserted_at],
        select: c

    Repo.all(query) |> Repo.preload(:members)
  end

  def chat_updates(from, limit) do
    query =
      from c in Chat,
        where: c.updated_at > ^from,
        limit: ^limit,
        select: c

    Repo.all(query) |> Repo.preload(:members)
  end

  def chat_updates(from, limit, member_id) do
    query =
      from c in Chat,
        join: cm in ChatMember,
        on: c.id == cm.chat_id,
        where: cm.user_id == ^member_id and c.updated_at > ^from,
        limit: ^limit,
        select: c

    Repo.all(query) |> Repo.preload(:members)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  def get_chat_with_members!(id), do: Repo.get!(Chat, id) |> Repo.preload(:members)

  def find_dialog(user1, user2) do
    query =
      from c in Chat,
        join: cm1 in ChatMember,
        on: c.id == cm1.chat_id,
        join: cm2 in ChatMember,
        on: c.id == cm2.chat_id,
        where: c.type == :dialog,
        where: cm1.user_id == ^user1,
        where: cm2.user_id == ^user2,
        select: c

    Repo.one(query) |> Repo.preload(:members)
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

  @doc """
  Returns the list of chat_members.

  ## Examples

      iex> list_chat_members()
      [%ChatMember{}, ...]

  """
  def list_chat_members do
    Repo.all(ChatMember)
  end

  def list_chat_members_by_chat_id(chat_id) do
    query =
      from cm in ChatMember,
        where: cm.chat_id == ^chat_id,
        select: cm

    Repo.all(query)
  end

  def add_chat_member(chat, chat_changes, member_params) do
    members_changeset = [member_params | chat.members]

    chat
    |> Ecto.Changeset.change(chat_changes)
    |> Ecto.Changeset.put_assoc(:members, members_changeset)
    |> Repo.update()
  end

  def update_chat_with_member(chat, chat_changes, member_id, member_changes) do
    members_changeset =
      Enum.map(chat.members, fn member ->
        if member.user_id == member_id,
          do: Map.merge(%{:id => member.id}, member_changes),
          else: %{:id => member.id}
      end)

    chat
    |> Ecto.Changeset.change(chat_changes)
    |> Ecto.Changeset.put_assoc(:members, members_changeset)
    |> Repo.update()
  end

  @doc """
  Gets a single chat_member.

  Raises `Ecto.NoResultsError` if the Chat member does not exist.

  ## Examples

      iex> get_chat_member!(123)
      %ChatMember{}

      iex> get_chat_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_member!(id), do: Repo.get!(ChatMember, id)

  @doc """
  Creates a chat_member.

  ## Examples

      iex> create_chat_member(%{field: value})
      {:ok, %ChatMember{}}

      iex> create_chat_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_member(attrs \\ %{}) do
    %ChatMember{}
    |> ChatMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat_member.

  ## Examples

      iex> update_chat_member(chat_member, %{field: new_value})
      {:ok, %ChatMember{}}

      iex> update_chat_member(chat_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_member(%ChatMember{} = chat_member, attrs) do
    chat_member
    |> ChatMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat_member.

  ## Examples

      iex> delete_chat_member(chat_member)
      {:ok, %ChatMember{}}

      iex> delete_chat_member(chat_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_member(%ChatMember{} = chat_member) do
    Repo.delete(chat_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_member changes.

  ## Examples

      iex> change_chat_member(chat_member)
      %Ecto.Changeset{data: %ChatMember{}}

  """
  def change_chat_member(%ChatMember{} = chat_member, attrs \\ %{}) do
    ChatMember.changeset(chat_member, attrs)
  end

  alias WTChat.Chats.ChatMessage

  @doc """
  Returns the list of chat_messages.

  ## Examples

      iex> list_chat_messages()
      [%ChatMessage{}, ...]

  """
  def message_history do
    query =
      from cm in ChatMessage,
        where: is_nil(cm.deleted_at),
        select: cm

    Repo.all(query)
  end

  def message_history(chat_id) do
    query =
      from cm in ChatMessage,
        where: cm.chat_id == ^chat_id and is_nil(cm.deleted_at),
        select: cm

    Repo.all(query)
  end

  def message_history(chat_id, limit) do
    query =
      from cm in ChatMessage,
        where: cm.chat_id == ^chat_id and is_nil(cm.deleted_at),
        order_by: [desc: cm.inserted_at],
        limit: ^limit,
        select: cm

    Repo.all(query)
  end

  def message_history(chat_id, from, limit) do
    query =
      from cm in ChatMessage,
        where: cm.chat_id == ^chat_id and cm.inserted_at < ^from and is_nil(cm.deleted_at),
        order_by: [desc: cm.inserted_at],
        limit: ^limit,
        select: cm

    Repo.all(query)
  end

  def message_updates(from, limit) do
    query =
      from cm in ChatMessage,
        where: cm.updated_at > ^from,
        limit: ^limit,
        select: cm

    Repo.all(query)
  end

  def message_updates(from, limit, chat_id) do
    query =
      from cm in ChatMessage,
        where: cm.chat_id == ^chat_id and cm.updated_at > ^from,
        limit: ^limit,
        select: cm

    Repo.all(query)
  end

  @doc """
  Gets a single chat_message.

  Raises `Ecto.NoResultsError` if the Chat message does not exist.

  ## Examples

      iex> get_chat_message!(123)
      %ChatMessage{}

      iex> get_chat_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(ChatMessage, id)

  def get_chat_message!(id), do: Repo.get!(ChatMessage, id) |> Repo.preload([:chat])

  def get_message_by_id_key!(id_key), do: Repo.get_by!(ChatMessage, idempotency_key: id_key)

  @doc """
  Creates a chat_message.

  ## Examples

      iex> create_chat_message(%{field: value})
      {:ok, %ChatMessage{}}

      iex> create_chat_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_message(attrs \\ %{}) do
    %ChatMessage{}
    |> ChatMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat_message.

  ## Examples

      iex> update_chat_message(chat_message, %{field: new_value})
      {:ok, %ChatMessage{}}

      iex> update_chat_message(chat_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_message(%ChatMessage{} = chat_message, attrs) do
    chat_message
    |> ChatMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat_message.

  ## Examples

      iex> delete_chat_message(chat_message)
      {:ok, %ChatMessage{}}

      iex> delete_chat_message(chat_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_message(%ChatMessage{} = chat_message) do
    Repo.delete(chat_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_message changes.

  ## Examples

      iex> change_chat_message(chat_message)
      %Ecto.Changeset{data: %ChatMessage{}}

  """
  def change_chat_message(%ChatMessage{} = chat_message, attrs \\ %{}) do
    ChatMessage.changeset(chat_message, attrs)
  end

  def mark_messages_as_viewed(message_ids, viewed_at) when is_list(message_ids) do
    ChatMessage
    |> where([m], m.id in ^message_ids)
    |> Repo.update_all(set: [viewed_at: viewed_at])
  end
end
