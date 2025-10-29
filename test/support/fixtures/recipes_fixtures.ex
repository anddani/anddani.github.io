defmodule App.RecipesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Recipes` context.
  """

  @doc """
  Generate a unique recipe slug.
  """
  def unique_recipe_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        image_url: "some image_url",
        ingredients: ["option1", "option2"],
        instructions: "some instructions",
        slug: unique_recipe_slug(),
        tags: ["option1", "option2"],
        title: "some title"
      })
      |> App.Recipes.create_recipe()

    recipe
  end
end
