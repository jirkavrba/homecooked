defmodule HomecookedWeb.PageController do
  use HomecookedWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def invalid_magic_link(conn, _params) do
    render(conn, :invalid_magic_link)
  end
end
