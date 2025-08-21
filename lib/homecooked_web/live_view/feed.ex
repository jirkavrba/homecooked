defmodule HomecookedWeb.LiveView.Feed do
  use HomecookedWeb, :live_view

  def mount(_params, session, socket) do
    with {:ok, user} <- Homecooked.Users.find_by_id(session["user_id"]),
         {:ok, feed_page} <- Homecooked.Posts.get_user_feed(user) do
      last_post = List.last(feed_page.entries)
      empty_feed = Enum.empty?(feed_page.entries)

      socket =
        socket
        |> assign(:user, user)
        |> assign(:last_post, last_post)
        |> assign(:reached_end, empty_feed)
        |> stream(:feed, feed_page.entries)

      {:ok, socket}
    else
      _ ->
        {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("load_more_posts", _params, socket) do
    user = socket.assigns[:user]
    last_post = socket.assigns[:last_post]

    with {:ok, new_feed_page} <- Homecooked.Posts.get_user_feed(user, last_post) do
      new_last_post = List.last(new_feed_page.entries)

      socket =
        socket
        |> assign(:last_post, new_last_post)
        |> assign(:reached_end, is_nil(new_last_post))
        |> stream(:feed, new_feed_page.entries, reset: false)

      {:noreply, socket}
    else
      _ ->
        {:noreply, push_navigate(socket, to: ~p"/")}
    end
  end
end
