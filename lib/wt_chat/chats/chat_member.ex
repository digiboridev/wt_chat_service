defmodule WTChat.Chats.ChatMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_members" do
    field :user_id, :string
    field :joined_at, :naive_datetime
    field :left_at, :naive_datetime
    field :blocked_at, :naive_datetime
    field :chat_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, [:user_id, :joined_at, :left_at, :blocked_at])
    |> validate_required([:user_id, :joined_at])
  end
end
