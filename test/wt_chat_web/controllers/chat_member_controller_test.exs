defmodule WTChatWeb.ChatMemberControllerTest do
  use WTChatWeb.ConnCase

  import WTChat.ChatsFixtures

  alias WTChat.Chats.ChatMember

  @create_attrs %{
    user_id: "some user_id",
    joined_at: ~N[2024-06-11 08:56:00],
    left_at: ~N[2024-06-11 08:56:00],
    blocked_at: ~N[2024-06-11 08:56:00]
  }
  @update_attrs %{
    user_id: "some updated user_id",
    joined_at: ~N[2024-06-12 08:56:00],
    left_at: ~N[2024-06-12 08:56:00],
    blocked_at: ~N[2024-06-12 08:56:00]
  }
  @invalid_attrs %{user_id: nil, joined_at: nil, left_at: nil, blocked_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all chat_members", %{conn: conn} do
      conn = get(conn, ~p"/api/chat_members")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create chat_member" do
    test "renders chat_member when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/chat_members", chat_member: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/chat_members/#{id}")

      assert %{
               "id" => ^id,
               "blocked_at" => "2024-06-11T08:56:00",
               "joined_at" => "2024-06-11T08:56:00",
               "left_at" => "2024-06-11T08:56:00",
               "user_id" => "some user_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/chat_members", chat_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update chat_member" do
    setup [:create_chat_member]

    test "renders chat_member when data is valid", %{conn: conn, chat_member: %ChatMember{id: id} = chat_member} do
      conn = put(conn, ~p"/api/chat_members/#{chat_member}", chat_member: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/chat_members/#{id}")

      assert %{
               "id" => ^id,
               "blocked_at" => "2024-06-12T08:56:00",
               "joined_at" => "2024-06-12T08:56:00",
               "left_at" => "2024-06-12T08:56:00",
               "user_id" => "some updated user_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, chat_member: chat_member} do
      conn = put(conn, ~p"/api/chat_members/#{chat_member}", chat_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete chat_member" do
    setup [:create_chat_member]

    test "deletes chosen chat_member", %{conn: conn, chat_member: chat_member} do
      conn = delete(conn, ~p"/api/chat_members/#{chat_member}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/chat_members/#{chat_member}")
      end
    end
  end

  defp create_chat_member(_) do
    chat_member = chat_member_fixture()
    %{chat_member: chat_member}
  end
end
