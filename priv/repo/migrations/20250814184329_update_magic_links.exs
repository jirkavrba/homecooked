defmodule Homecooked.Repo.Migrations.UpdateMagicLinks do
  use Ecto.Migration

  def change do
    rename table(:magic_links), :expires, to: :expiration
  end
end
