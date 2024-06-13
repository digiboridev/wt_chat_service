defmodule WTChat.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create table(:chat_members) do
      add :chat_id, references(:chats, on_delete: :delete_all)
      add :user_id, :string, null: false
      add :joined_at, :utc_datetime_usec, null: false
      add :left_at, :utc_datetime_usec
      add :blocked_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create index(:chat_members, [:chat_id])
    create index(:chat_members, [:user_id])
    create index(:chat_members, [:chat_id,:user_id])
  end
end
