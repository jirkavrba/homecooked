defmodule HomecookedWeb.LiveView.Profile do
  use HomecookedWeb, :live_view

  alias Homecooked.Repo
  alias Homecooked.Users

  def mount(_params, session, socket) do
    with {:ok, user} <- Users.find_by_id(session["user_id"]),
         user_with_followed_users <- Repo.preload(user, :followed_users) do
      socket =
        socket
        |> assign(:user, user_with_followed_users)
        |> assign(:form, to_form(%{"follow_code" => ""}))

      {:ok, socket}
    else
      _ -> {:ok, redirect(socket, to: ~p"/")}
    end
  end

  def handle_event("start_following", %{"follow_code" => code}, socket) do
    user = socket.assigns.user

    case Users.start_following_with_code(user, code) do
      {:ok, newly_followed_user} ->
        {:noreply,
         update(socket, :user, fn user ->
           updated_followed_users =
             user.followed_users
             |> Kernel.++([newly_followed_user])
             |> Enum.uniq_by(& &1.discord_id)

           %{user | followed_users: updated_followed_users}
         end)}

      _ ->
        {:noreply, socket}
    end
  end
end
