defmodule HomecookedWeb.LiveView.Post.Create do
  use HomecookedWeb, :live_view

  alias Homecooked.Posts
  alias Homecooked.Posts.Post
  alias Phoenix.LiveView.UploadEntry

  def mount(_params, session, socket) do
    with {:ok, user} <- Homecooked.Users.find_by_id(session["user_id"]) do
      form =
        %Post{}
        |> Posts.change_post()
        |> to_form()

      socket =
        socket
        |> assign(user: user, form: form, ingredients: [], recipe_steps: [], valid?: false)
        |> allow_upload(:image,
          auto_upload: true,
          accept: ~w(.jpg .jpeg .png),
          max_entries: 1,
          max_file_size: 10_000_000
        )

      {:ok, socket}
    else
      _ ->
        {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("validate", %{"post" => params}, socket) do
    image_url =
      case socket.assigns.uploads.image.entries do
        [%UploadEntry{done?: true, uuid: uuid}] -> uuid
        _ -> nil
      end

    params = Map.put(params, "image_url", image_url)

    form =
      %Post{}
      |> Posts.change_post(params)
      |> to_form(action: :validate)

    socket =
      socket
      |> assign(form: form)
      |> assign(valid?: Enum.empty?(form.errors))

    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    user = socket.assigns.user

    [image_url] =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        Posts.upload_post_image(path)
      end)

    recipe =
      if Enum.empty?(socket.assigns.recipe_steps),
        do: nil,
        else: Enum.join(socket.assigns.recipe_steps, "\n")

    ingredients_list =
      if Enum.empty?(socket.assigns.ingredients),
        do: nil,
        else: Enum.join(socket.assigns.ingredients, "\n")

    post =
      post_params
      |> Map.put("image_url", image_url)
      |> Map.put("recipe", recipe)
      |> Map.put("ingredients_list", ingredients_list)
      |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
      |> Posts.create_post(user)

    case post do
      {:ok, _post} -> {:noreply, push_navigate(socket, to: ~p"/app/feed")}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("cancel_image_upload", %{"ref" => ref}, socket) do
    socket =
      socket
      |> cancel_upload(:image, ref)

    {:noreply, socket}
  end

  def handle_event("add_ingredient", _params, socket) do
    {:noreply, update(socket, :ingredients, &(&1 ++ [""]))}
  end

  def handle_event("update_ingredients", %{"ingredients" => ingredients}, socket) do
    {:noreply, assign(socket, :ingredients, ingredients)}
  end

  def handle_event("delete_ingredient", %{"index" => index}, socket) do
    casted_index = String.to_integer(index)
    updated_ingredients = List.delete_at(socket.assigns.ingredients, casted_index)
    {:noreply, assign(socket, :ingredients, updated_ingredients)}
  end

  def handle_event("add_recipe_step", _params, socket) do
    {:noreply, update(socket, :recipe_steps, &(&1 ++ [""]))}
  end

  def handle_event("update_recipe_steps", %{"recipe_steps" => recipe_steps}, socket) do
    {:noreply, assign(socket, :recipe_steps, recipe_steps)}
  end

  def handle_event("delete_recipe_step", %{"index" => index}, socket) do
    casted_index = String.to_integer(index)
    updated_recipe_steps = List.delete_at(socket.assigns.recipe_steps, casted_index)
    {:noreply, assign(socket, :recipe_steps, updated_recipe_steps)}
  end
end
