defmodule Homecooked.Users.MagicLink do
  use Ecto.Schema
  import Ecto.Changeset
  alias Homecooked.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "magic_links" do
    field :token, :string
    field :expiration, :utc_datetime

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(magic_link, attrs) do
    magic_link
    |> cast(attrs, [:user_id, :token, :expiration])
    |> validate_required([:user_id, :token, :expiration])
    |> unique_constraint(:token)
  end
end
