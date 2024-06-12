defmodule WTChatWeb.ChatMessageControllerTest do
  use WTChatWeb.ConnCase

  import WTChat.ChatsFixtures

  alias WTChat.Chats.ChatMessage

  @create_attrs %{
    sender_id: "some sender_id",
    reply_to_id: "some reply_to_id",
    author_id: "some author_id",
    via_sms: true,
    sms_out_state: :sending,
    sms_number: "some sms_number",
    content: "some content",
    edited_at: ~N[2024-06-11 11:46:00],
    deleted_at: ~N[2024-06-11 11:46:00]
  }
  @update_attrs %{
    sender_id: "some updated sender_id",
    reply_to_id: "some updated reply_to_id",
    author_id: "some updated author_id",
    via_sms: false,
    sms_out_state: :error,
    sms_number: "some updated sms_number",
    content: "some updated content",
    edited_at: ~N[2024-06-12 11:46:00],
    deleted_at: ~N[2024-06-12 11:46:00]
  }
  @invalid_attrs %{sender_id: nil, reply_to_id: nil, author_id: nil, via_sms: nil, sms_out_state: nil, sms_number: nil, content: nil, edited_at: nil, deleted_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all chat_messages", %{conn: conn} do
      conn = get(conn, ~p"/api/chat_messages")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create chat_message" do
    test "renders chat_message when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/chat_messages", chat_message: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/chat_messages/#{id}")

      assert %{
               "id" => ^id,
               "author_id" => "some author_id",
               "content" => "some content",
               "deleted_at" => "2024-06-11T11:46:00",
               "edited_at" => "2024-06-11T11:46:00",
               "reply_to_id" => "some reply_to_id",
               "sender_id" => "some sender_id",
               "sms_number" => "some sms_number",
               "sms_out_state" => "sending",
               "via_sms" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/chat_messages", chat_message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update chat_message" do
    setup [:create_chat_message]

    test "renders chat_message when data is valid", %{conn: conn, chat_message: %ChatMessage{id: id} = chat_message} do
      conn = put(conn, ~p"/api/chat_messages/#{chat_message}", chat_message: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/chat_messages/#{id}")

      assert %{
               "id" => ^id,
               "author_id" => "some updated author_id",
               "content" => "some updated content",
               "deleted_at" => "2024-06-12T11:46:00",
               "edited_at" => "2024-06-12T11:46:00",
               "reply_to_id" => "some updated reply_to_id",
               "sender_id" => "some updated sender_id",
               "sms_number" => "some updated sms_number",
               "sms_out_state" => "error",
               "via_sms" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, chat_message: chat_message} do
      conn = put(conn, ~p"/api/chat_messages/#{chat_message}", chat_message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete chat_message" do
    setup [:create_chat_message]

    test "deletes chosen chat_message", %{conn: conn, chat_message: chat_message} do
      conn = delete(conn, ~p"/api/chat_messages/#{chat_message}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/chat_messages/#{chat_message}")
      end
    end
  end

  defp create_chat_message(_) do
    chat_message = chat_message_fixture()
    %{chat_message: chat_message}
  end
end
