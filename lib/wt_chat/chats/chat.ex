defmodule WTChat.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :name, :string
    field :type, Ecto.Enum, values: [:dialog, :group]
    field :creator_id, :string
    field :deleted_at, :utc_datetime_usec
    field :v, :integer, default: 1
    has_many :members, WTChat.Chats.ChatMember, on_replace: :delete_if_exists
    has_many :messages, WTChat.Chats.ChatMessage, on_replace: :raise
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> (cast(attrs, [
          :id,
          :type,
          :name,
          :creator_id,
          :deleted_at,
          :updated_at
        ])
        |> cast_assoc(:members)
        |> cast_assoc(:messages)
        |> validate_required([:type, :creator_id])
        |> optimistic_lock(:v))
  end
end


# TODO: Introduce group chat owner field and moderator role for members
