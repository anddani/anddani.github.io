defmodule AppWeb.RecipesLayouts do
  use Phoenix.Component
  alias AppWeb.Surfaces
  alias App.Recipes.Recipe

  def recipe_item(%{recipe: %Recipe{}} = assigns) do
    ~H"""
    <Surfaces.frame class="p-4 flex flex-col gap-2">
      <p>{@recipe.title}</p>
      <p>{@recipe.slug}</p>
      <p>{@recipe.ingredients}</p>
      <p>{@recipe.instructions}</p>
      <p>{@recipe.tags}</p>
      <p>{@recipe.image_url}</p>
      <p>{@recipe.inserted_at}</p>
    </Surfaces.frame>
    """
  end
end
