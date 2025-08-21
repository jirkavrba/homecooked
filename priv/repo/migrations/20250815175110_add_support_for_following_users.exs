defmodule Homecooked.Repo.Migrations.AddSupportForFollowingUsers do
  use Ecto.Migration

  def change do
    create table(:followers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :followed_user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    alter table(:users) do
      add :follow_code, :string, default: ""
    end

    create unique_index(:users, :follow_code)
  end
end
