defmodule Homecooked.Users do
  alias Homecooked.Users.Following
  alias Homecooked.Repo
  alias Homecooked.Users.MagicLink
  alias Homecooked.Users.User
  import Ecto.Query, only: [from: 2]

  @spec upsert(binary(), binary(), binary() | nil, binary() | nil) ::
          {:ok, %User{}} | {:error, term()}
  def upsert(discord_id, username, display_name, avatar_url) do
    attrs = %{
      discord_id: discord_id,
      username: username,
      display_name: display_name,
      avatar_url: avatar_url
    }

    base_user =
      Repo.get_by(User, discord_id: discord_id) || %User{follow_code: generate_follow_code()}

    base_user
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @spec find_by_id(binary()) :: {:ok, %User{}} | {:error, term()}
  def find_by_id(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, "User was not found."}
      user -> {:ok, user}
    end
  end

  @spec find_by_follow_code(binary()) :: {:ok, %User{}} | {:error, term()}
  def find_by_follow_code(follow_code) do
    case Repo.get_by(User, follow_code: follow_code) do
      nil -> {:error, "User with this follow code was not found."}
      user -> {:ok, user}
    end
  end

  @spec find_by_magic_link_token(binary()) :: {:ok, %User{}} | {:error, term()}
  def find_by_magic_link_token(token) do
    now = DateTime.utc_now()

    query =
      from u in User,
        join: m in MagicLink,
        on: m.user_id == u.id,
        where: m.token == ^token,
        where: m.expiration > ^now,
        select: u

    case Repo.one(query) do
      nil -> {:error, "Magic link not found or expired."}
      user -> {:ok, user}
    end
  end

  @spec generate_magic_link_for(%User{}) :: {:ok, %MagicLink{}} | {:error, term()}
  def generate_magic_link_for(%User{id: user_id}) do
    attrs = %{
      user_id: user_id,
      expiration: generate_magic_link_expiration(),
      token: generate_magic_link_token()
    }

    %MagicLink{}
    |> MagicLink.changeset(attrs)
    |> Repo.insert()
  end

  @spec regenerate_follow_code_for(%User{}) :: {:ok, %User{}} | {:error, term()}
  def regenerate_follow_code_for(%User{} = user) do
    new_follow_code = generate_follow_code()

    attrs = %{
      follow_code: new_follow_code
    }

    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec start_following_with_code(%User{}, binary()) :: {:ok, %User{}} | {:error, term()}
  def start_following_with_code(%User{} = user, follow_code) do
    with {:ok, followed_user} <- find_by_follow_code(follow_code) do
      attrs = %{
        user_id: user.id,
        followed_user_id: followed_user.id
      }

      stored_following =
        %Following{}
        |> Following.changeset(attrs)
        |> Repo.insert()

      case stored_following do
        {:ok, _following} -> {:ok, followed_user}
        {:error, error} -> {:error, error}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  @magic_link_expiration_hours 24
  @spec generate_magic_link_expiration() :: DateTime.t()
  defp generate_magic_link_expiration() do
    DateTime.add(DateTime.utc_now(), @magic_link_expiration_hours, :hour)
  end

  @magic_link_token_bytes 32
  @spec generate_magic_link_token() :: binary()
  defp generate_magic_link_token() do
    @magic_link_token_bytes
    |> :rand.bytes()
    |> Base.encode16(case: :lower)
  end

  @follow_code_charaters 6
  @spec generate_follow_code() :: binary()
  defp generate_follow_code() do
    for _ <- 1..@follow_code_charaters, into: "", do: <<Enum.random(?0..?9)>>
  end
end
