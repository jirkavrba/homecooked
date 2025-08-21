defmodule HomecookedWeb.BotController do
  use HomecookedWeb, :controller

  alias Homecooked.Users

  @magic_link_schema %{
    discord_id: [type: :string, required: true],
    username: [type: :string, required: true],
    display_name: :string,
    avatar_url: :string
  }

  def generate_magic_link(conn, params) do
    with {:ok, params} <- Tarams.cast(params, @magic_link_schema),
         {:ok, user} <-
           Users.upsert(
             params[:discord_id],
             params[:username],
             params[:display_name],
             params[:avatar_url]
           ),
         {:ok, magic_link} <- Users.generate_magic_link_for(user) do
      full_magic_link = Phoenix.VerifiedRoutes.url(~p"/login/magic-link/#{magic_link.token}")

      conn
      |> json(%{
        magic_link: full_magic_link,
        expiration: magic_link.expiration
      })
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error})
    end
  end
end
