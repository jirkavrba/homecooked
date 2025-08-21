defmodule HomecookedWeb.AuthController do
  require Logger
  alias Homecooked.Users
  use HomecookedWeb, :controller

  def login_with_magic_link(conn, %{"token" => token}) do
    with {:ok, user} <- Users.find_by_magic_link_token(token) do
      conn
      |> put_session(:user_id, user.id)
      |> redirect(to: ~p"/app/feed")
    else
      {:error, reason} ->
        Logger.error("Error signing with magic link token: #{reason}")

        conn
        |> redirect(to: ~p"/login/magic-link/invalid")
    end
  end
end
