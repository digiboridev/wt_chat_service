defmodule WTChatWeb.ChatChannel do
  use Phoenix.Channel

  # Service channel that needs to reply user with the user_id that verified in the connect function
  def join("chat:auth", _message, socket) do
    userId = socket.assigns.user_id
    IO.puts("chat:auth joined: #{userId}")
    {:ok, %{"user_id" => userId}, socket}
  end

  # Channel for events that related to the specific user
  def join("chat:user:" <> user_id, _message, socket) do
    socket_user_id = socket.assigns.user_id
    cond do
      socket_user_id == user_id ->
        {:ok, socket}
      true ->
        {:error, %{reason: "trying to join a chat that is not yours"}}
    end
  end

  @spec handle_in(any(), any(), any()) :: {:noreply, any()}
  def handle_in(event, payload, socket) do
    IO.puts(event)
    IO.puts(payload)
    {:noreply, socket}
  end
end
