defmodule WTChat.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :name, :string
    field :type, Ecto.Enum, values: [:dialog, :group]
    field :creator_id, :string
    field :edited_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:type, :name, :creator_id, :edited_at, :deleted_at])
    |> validate_required([:type, :creator_id])
  end
end
