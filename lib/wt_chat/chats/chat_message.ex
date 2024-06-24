defmodule WTChat.Chats.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :sender_id, :string
    field :chat_id, :id
    field :reply_to_id, :string
    field :forwarded_from_id, :id
    field :author_id, :string
    field :via_sms, :boolean, default: false
    field :sms_out_state, Ecto.Enum, values: [:sending, :error, :delivered]
    field :sms_number, :string
    field :content, :string
    field :idempotency_key, :string
    field :viewed_at, :utc_datetime_usec
    field :edited_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    belongs_to :chat, WTChat.Chats.Chat, define_field: false, on_replace: :update
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [
      :chat_id,
      :sender_id,
      :reply_to_id,
      :author_id,
      :via_sms,
      :sms_out_state,
      :sms_number,
      :content,
      :idempotency_key,
      :viewed_at,
      :edited_at,
      :deleted_at
    ])
    |> cast_assoc(:chat)
    |> validate_required([:sender_id, :content])
    |> unique_constraint(:idempotency_key)
  end
end
