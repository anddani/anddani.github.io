defmodule App.RecipesTest do
  use App.DataCase

  alias App.Recipes

  describe "recipes" do
    alias App.Recipes.Recipe

    import App.RecipesFixtures

    @invalid_attrs %{
      instructions: nil,
      title: nil,
      slug: nil,
      ingredients: nil,
      tags: nil,
      image_url: nil
    }

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Recipes.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Recipes.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      valid_attrs = %{
        instructions: "some instructions",
        title: "some title",
        slug: "some slug",
        ingredients: ["option1", "option2"],
        tags: ["option1", "option2"],
        image_url: "some image_url"
      }

      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(valid_attrs)
      assert recipe.instructions == "some instructions"
      assert recipe.title == "some title"
      assert recipe.slug == "some slug"
      assert recipe.ingredients == ["option1", "option2"]
      assert recipe.tags == ["option1", "option2"]
      assert recipe.image_url == "some image_url"
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()

      update_attrs = %{
        instructions: "some updated instructions",
        title: "some updated title",
        slug: "some updated slug",
        ingredients: ["option1"],
        tags: ["option1"],
        image_url: "some updated image_url"
      }

      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(recipe, update_attrs)
      assert recipe.instructions == "some updated instructions"
      assert recipe.title == "some updated title"
      assert recipe.slug == "some updated slug"
      assert recipe.ingredients == ["option1"]
      assert recipe.tags == ["option1"]
      assert recipe.image_url == "some updated image_url"
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Recipes.change_recipe(recipe)
    end
  end
end
