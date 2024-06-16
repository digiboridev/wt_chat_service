defmodule WTChat.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :sender_id, :string, null: false
      add :chat_id, references(:chats, on_delete: :delete_all)
      add :reply_to_id, :string
      add :forwarded_from_id, references(:chats, on_delete: :nothing)
      add :author_id, :string
      add :via_sms, :boolean, default: false, null: false
      add :sms_out_state, :string
      add :sms_number, :string
      add :content, :text, null: false
      add :idempotency_key, :string, null: false
      add :created_at, :utc_datetime_usec, null: false
      add :edited_at, :utc_datetime_usec
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create index(:chat_messages, [:chat_id])
    create index(:chat_messages, [:forwarded_from_id])
    create index(:chat_messages, [:inserted_at])
    create index(:chat_messages, [:updated_at])
    create unique_index(:chat_messages, [:idempotency_key])
  end
end
