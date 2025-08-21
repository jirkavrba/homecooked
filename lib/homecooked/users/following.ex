defmodule Homecooked.Users.Following do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homecooked.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "followings" do
    belongs_to :user, User
    belongs_to :followed_user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id, :followed_user_id])
    |> validate_required([:user_id, :followed_user_id])
  end
end
