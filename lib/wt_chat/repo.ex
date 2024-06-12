defmodule WTChat.Repo do
  use Ecto.Repo,
    otp_app: :wt_chat,
    adapter: Ecto.Adapters.Postgres
end
