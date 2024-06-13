defmodule WTChat.Chats.ChatMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_members" do
    field :chat_id, :id
    field :user_id, :string
    field :joined_at, :utc_datetime_usec
    field :left_at, :utc_datetime_usec
    field :blocked_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, [:user_id, :joined_at, :left_at, :blocked_at])
    |> validate_required([:user_id, :joined_at])
  end
end
