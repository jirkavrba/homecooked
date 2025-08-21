defmodule Homecooked.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :discord_id, :string, null: false
      add :username, :string, null: false
      add :display_name, :string
      add :avatar_url, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:discord_id])
  end
end
