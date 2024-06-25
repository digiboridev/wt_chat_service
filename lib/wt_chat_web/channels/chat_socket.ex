defmodule WTChatWeb.ChatSocket do
  use Phoenix.Socket

  channel "chat:*", WTChatWeb.ChatChannel

  @impl true
  def connect(params, socket, _connect_info) do
    token = params |> Map.get("token")
    tenant_id = params |> Map.get("tenant_id")

    case parse_token(token, tenant_id) do
      {:ok, user_id} ->
        {:ok, assign(socket, user_id: user_id)}

      _ ->
        :error
    end
  end

  @impl true
  def id(_socket), do: nil

  defp parse_token(nil, nil) do
    {:ok, "123009"}
  end

  defp parse_token(token, tenant_id) do
    uri = "#{System.get_env("CORE_URI")}/tenant/#{tenant_id}/api/v1/user"
    headers = [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]

    response = HTTPoison.get(uri, headers)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        json = Jason.decode!(body)
        main_number = json["numbers"]["main"]
        {:ok, main_number}

      _ ->
        :error
    end
  end
end
