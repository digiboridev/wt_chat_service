defmodule WTChatWeb.ChatController do
  use WTChatWeb, :controller

  alias WTChat.ChatService

  action_fallback WTChatWeb.FallbackController

  def index(conn, params) do
    chats = ChatService.index(params)
    render(conn, :index, chats: chats)
  end

  def create(conn, %{"chat" => chat_params}) do
    case ChatService.create(%{"chat" => chat_params}) do
      {:ok, chat} -> render(conn, :show, chat: chat)
      {:error, reason} -> render(conn, :error, reason: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    chat = ChatService.show(%{"id" => id})
    render(conn, :show, chat: chat)
  end

  def update(conn, %{"id" => id, "chat" => chat_params}) do
    case ChatService.update(%{"id" => id, "chat" => chat_params}) do
      {:ok, chat} -> render(conn, :show, chat: chat)
      {:error, reason} -> render(conn, :error, reason: reason)
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
end
