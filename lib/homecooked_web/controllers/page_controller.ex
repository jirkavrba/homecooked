defmodule HomecookedWeb.PageController do
  use HomecookedWeb, :controller

  def home(conn, _params) do
    case get_session(conn, :user_id) do
      nil -> render(conn, :home)
      _ -> redirect(conn, to: ~p"/app/feed")
    end
  end

  def invalid_magic_link(conn, _params) do
    render(conn, :invalid_magic_link)
  end
end
