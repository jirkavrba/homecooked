defmodule HomecookedWeb.BotAuthentication do
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    username = System.get_env("BOT_USERNAME")
    password = System.get_env("BOT_PASSWORD")

    case Plug.BasicAuth.parse_basic_auth(conn) do
      {^username, ^password} ->
        conn

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: 401,
          error: "Unauthorized",
          timestamp: DateTime.utc_now()
        })
        |> halt()
    end
  end
end
