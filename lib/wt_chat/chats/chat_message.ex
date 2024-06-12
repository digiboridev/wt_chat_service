defmodule WTChat.Chats.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :sender_id, :string
    field :reply_to_id, :string
    field :author_id, :string
    field :via_sms, :boolean, default: false
    field :sms_out_state, Ecto.Enum, values: [:sending, :error, :delivered]
    field :sms_number, :string
    field :content, :string
    field :edited_at, :naive_datetime
    field :deleted_at, :naive_datetime
    field :chat_id, :id
    field :forwarded_from_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:sender_id, :reply_to_id, :author_id, :via_sms, :sms_out_state, :sms_number, :content, :edited_at, :deleted_at])
    |> validate_required([:sender_id, :content])
  end
end
