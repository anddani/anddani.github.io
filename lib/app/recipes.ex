defmodule App.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false

  alias App.Recipes.Recipe
  alias App.Recipes.Cache

  @doc """
  Returns the list of recipes from cache.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Cache.list_recipes()
  end

  @doc """
  Gets a recipe by slug from cache.

  Returns nil if the recipe does not exist.

  ## Examples

      iex> get_recipe_by_slug("mentsuyu")
      %Recipe{}

      iex> get_recipe_by_slug("nonexistent")
      nil

  """
  def get_recipe_by_slug(slug) do
    Cache.get_by_slug(slug)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end

  @doc """
  Searches for recipes based on a query.

  ## Examples

      iex> search_recipes("query")
      [%Recipe{}, ...]

  """
  def search_recipes(query) do
    recipes = list_recipes()
    query_downcase = String.downcase(query)

    Enum.filter(recipes, fn recipe ->
      String.contains?(String.downcase(recipe.title), query_downcase)
    end)
  end
end
