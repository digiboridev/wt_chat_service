defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel


  def join("chat:auth", _message, socket) do
    userId = socket.assigns.user_id
    IO.puts("chat:auth joined: #{userId}")
    {:ok, %{"user_id" => userId}, socket}
  end

  @spec handle_in(any(), any(), any()) :: {:noreply, any()}
  def handle_in(event, payload, socket) do
    IO.puts(event)
    IO.puts(payload)
    {:noreply, socket}
  end
end
