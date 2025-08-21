defmodule HomecookedWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use HomecookedWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :user, :map, required: true

  attr :flash, :map, required: true

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar flex bg-base-100 shadow-sm">
      <div class="flex-1 pl-2">
        <a class="btn btn-ghost text-xl" href={~p"/app/feed"}>Homecooked</a>
      </div>

      <div class="flex-none">
        <a href={~p"/app/profile"}>
          <div class="avatar pr-6">
            <div class="size-8 rounded-full ring-primary ring-offset-base-100 ring-2 ring-offset-2">
              <img src={@user.avatar_url} />
            </div>
          </div>
        </a>
      </div>
    </header>
    <main class="container mx-auto flex flex-col gap-8 p-8 mb-16">
      {render_slot(@inner_block)}
    </main>
    """
  end
end
