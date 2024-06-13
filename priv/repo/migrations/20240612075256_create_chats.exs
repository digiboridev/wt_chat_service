defmodule WTChat.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :name, :string
      add :type, :string, null: false
      add :creator_id, :string, null: false
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end
  end
end
