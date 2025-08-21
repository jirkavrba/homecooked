defmodule Homecooked.Repo.Migrations.RenameFollowersTable do
  use Ecto.Migration

  def change do
    rename table(:followers), to: table(:followings)
  end
end
