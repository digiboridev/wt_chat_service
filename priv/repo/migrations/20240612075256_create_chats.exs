defmodule WTChat.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :type, :string, null: false
      add :name, :string
      add :creator_id, :string, null: false
      add :edited_at, :naive_datetime
      add :deleted_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
