defmodule WTChatWeb.ChatController do
  use WTChatWeb, :controller

  alias WTChat.ChatService

  action_fallback WTChatWeb.FallbackController

  def chat_list(conn, params) do
    member_id = Map.get(params, "member_id")

    chats = ChatService.chat_list(member_id)
    render(conn, :index, chats: chats)
  end

  def chat_updates(conn, params) do
    member_id = Map.get(params, "member_id")
    from = Map.get(params, "from")
    limit = Map.get(params, "limit", 200)

    chats = ChatService.chat_updates(member_id, from, limit)
    render(conn, :index, chats: chats)
  end

  def create(conn, %{"chat" => chat_params}) do
    with {:ok, chat} <- ChatService.create(chat_params) do
      render(conn, :show, chat: chat)
    end
  end

  def show(conn, %{"id" => chat_id}) do
    with {:ok, chat} <- ChatService.get_by_id(chat_id) do
      render(conn, :show, chat: chat)
    end
  end

  def update(conn, %{"id" => chat_id, "chat" => chat_params}) do
    with {:ok, chat} <- ChatService.update(chat_id, chat_params) do
      render(conn, :show, chat: chat)
    end
  end

  def add_member(conn, %{"id" => chat_id, "member_id" => member_id, "user_id" => user_id}) do
    with {:ok, chat} <- ChatService.add_member(chat_id, member_id, user_id) do
      render(conn, :show, chat: chat)
    end
  end

  def leave_chat(conn, %{"id" => chat_id, "member_id" => member_id}) do
    with {:ok, chat} <- ChatService.leave_chat(chat_id, member_id) do
      render(conn, :show, chat: chat)
    end
  end

  def block_member(conn, %{"id" => chat_id, "member_id" => member_id, "user_id" => user_id}) do
    with {:ok, chat} <- ChatService.block_member(chat_id, member_id, user_id) do
      render(conn, :show, chat: chat)
    end
  end

  def delete(conn, %{"id" => id}) do
    case ChatService.delete(%{"id" => id}) do
      {:ok, chat} -> render(conn, :show, chat: chat)
      {:error, reason} -> render(conn, :error, reason: reason)
    end
  end

  def soft_delete(conn, %{"id" => id}) do
    case ChatService.soft_delete(%{"id" => id}) do
      {:ok, chat} -> render(conn, :show, chat: chat)
      {:error, reason} -> render(conn, :error, reason: reason)
    end
  end

  def find_dialog(conn, %{"from_user" => from_user, "to_user" => to_user}) do
    case ChatService.find_dialog(from_user, to_user) do
      {:ok, chat} -> render(conn, :show, chat: chat)
      nil -> json(conn, %{error: "Dialog not found"})
    end
  end
end
