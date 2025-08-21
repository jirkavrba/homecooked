defmodule HomecookedWeb.UserAuthentication do
  alias Homecooked.Repo
  alias Homecooked.Users.User
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    with user_id when not is_nil(user_id) <- get_session(conn, :user_id),
         user when not is_nil(user) <- Repo.get(User, user_id) do
      conn
      |> assign(:user, user)
    else
      _ ->
        conn
        |> redirect(to: "/")
        |> halt()
    end
  end
end
