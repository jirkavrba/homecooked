defmodule Homecooked.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image_url, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :ingredients_list, :text
      add :recipe, :text
      add :rating, :integer
      add :price_czk_per_portion, :integer
      add :kcal_per_portion, :integer
      add :preparation_time_minutes, :integer
      add :share_token, :string

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:user_id])
    create unique_index(:posts, :share_token)
  end
end
