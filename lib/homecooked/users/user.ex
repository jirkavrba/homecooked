defmodule Homecooked.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homecooked.Posts.Post
  alias Homecooked.Users.MagicLink
  alias Homecooked.Users.Following

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :discord_id, :string
    field :username, :string
    field :display_name, :string
    field :avatar_url, :string
    field :follow_code, :string

    has_many :posts, Post
    has_many :magic_links, MagicLink
    has_many :followings, Following
    has_many :followed_users, through: [:followings, :followed_user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:discord_id, :username, :display_name, :avatar_url, :follow_code])
    |> validate_required([:discord_id, :username, :follow_code])
    |> unique_constraint(:discord_id)
    |> unique_constraint(:follow_code)
  end
end
