defmodule Homecooked.Posts do
  alias Homecooked.Repo
  alias Homecooked.Posts.Post
  alias Homecooked.Users.User
  import Ecto.Query, only: [from: 2]

  def create_post(attrs, user) do
    share_token = Base.encode16(:rand.bytes(16), case: :lower)

    attrs =
      attrs
      |> Map.put(:user_id, user.id)
      |> Map.put(:share_token, share_token)

    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def change_post(post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def upload_post_image(path) do
    with {:ok, original_raw} <- File.read(path),
         {:ok, original} <- Image.from_binary(original_raw),
         {:ok, resized} <- Image.thumbnail(original, 512),
         {:ok, temp_file} <- create_temp_file(),
         {:ok, _result} <- Image.write(resized, temp_file),
         {:ok, uploaded_file_url} <- upload_file(temp_file) do
      {:ok, uploaded_file_url}
    else
      _ -> {:error, "Error uploading image."}
    end
  end

  defp create_temp_file() do
    case System.tmp_dir() do
      nil ->
        {:error, "Cannot create temp file"}

      temp_dir ->
        random_hash = Base.encode16(:rand.bytes(16), case: :lower)
        temp_file = Path.join(temp_dir, "#{random_hash}.jpg")

        {:ok, temp_file}
    end
  end

  defp upload_file(temp_file) do
    form = %{
      UPLOADCARE_STORE: 1,
      UPLOADCARE_PUB_KEY: System.get_env("UPLOADCARE_API_PUBLIC_KEY"),
      file: File.stream!(temp_file)
    }

    case Req.post("https://upload.uploadcare.com/base/", form_multipart: form) |> dbg() do
      {:ok, %Req.Response{status: 200, body: %{"file" => file_id}}} ->
        {:ok, "https://ucarecdn.com/#{file_id}/"}

      _ ->
        {:error, "Error uploading file to uploadcare."}
    end
  end

  @spec get_user_feed(%User{}, %Post{} | nil) :: {:ok, Paginator.Page.t()} | {:error, term()}
  def get_user_feed(user, last_post \\ nil) do
    user = Repo.preload(user, :followed_users)
    followed_user_ids = Enum.map(user.followed_users, fn %User{id: id} -> id end)
    all_user_ids = followed_user_ids ++ [user.id]

    last_post_cursor =
      if is_nil(last_post),
        do: nil,
        else: Paginator.cursor_for_record(last_post, [:inserted_at, :id])

    query =
      from p in Post,
        where: p.user_id in ^all_user_ids,
        preload: :user,
        order_by: [desc: :inserted_at]

    page =
      Repo.paginate(query,
        after: last_post_cursor,
        cursor_fields: [{:inserted_at, :desc}, :id]
      )

    {:ok, page}
  end
end
