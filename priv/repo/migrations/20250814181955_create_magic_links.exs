defmodule Homecooked.Repo.Migrations.CreateMagicLinks do
  use Ecto.Migration

  def change do
    create table(:magic_links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :string
      add :expires, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:magic_links, [:token])
    create index(:magic_links, [:user_id])
  end
end
