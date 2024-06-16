defmodule WTChat.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :name, :string
      add :type, :string, null: false
      add :creator_id, :string, null: false
      add :last_msg_preview, :string
      add :last_msg_at, :utc_datetime_usec
      add :last_msg_sender_id, :string
      add :last_msg_id, :integer
      add :message_count, :integer
      add :deleted_at, :utc_datetime_usec
      add :v, :integer, default: 1
      timestamps(type: :utc_datetime_usec)
    end
  end
end
