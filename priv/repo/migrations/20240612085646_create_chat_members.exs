defmodule WTChat.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create table(:chat_members) do
      add :user_id, :string, null: false
      add :joined_at, :naive_datetime, null: false
      add :left_at, :naive_datetime
      add :blocked_at, :naive_datetime
      add :chat_id, references(:chats, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:chat_members, [:chat_id])
  end
end
