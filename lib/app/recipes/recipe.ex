defmodule App.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field(:title, :string)
    field(:slug, :string)
    field(:ingredients, {:array, :string})
    field(:instructions, :string)
    field(:tags, {:array, :string})
    field(:image_url, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :slug, :ingredients, :instructions, :tags, :image_url])
    |> validate_required([:title, :slug, :ingredients, :instructions, :tags])
    |> unique_constraint(:slug)
  end
end
