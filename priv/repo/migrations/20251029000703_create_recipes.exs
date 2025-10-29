defmodule App.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add(:title, :string)
      add(:slug, :string)
      add(:ingredients, {:array, :string})
      add(:instructions, :text)
      add(:tags, {:array, :string})
      add(:image_url, :text)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:recipes, [:slug]))
  end
end
