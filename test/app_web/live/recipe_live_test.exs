defmodule AppWeb.RecipeLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.RecipesFixtures

  defp create_recipe(_) do
    recipe = recipe_fixture()

    %{recipe: recipe}
  end

  describe "Index" do
    setup [:create_recipe]

    test "lists all recipes", %{conn: conn, recipe: recipe} do
      {:ok, _index_live, html} = live(conn, ~p"/recipes")

      assert html =~ "Listing Recipes"
      assert html =~ recipe.title
    end

    # test "deletes recipe in listing", %{conn: conn, recipe: recipe} do
    #   {:ok, index_live, _html} = live(conn, ~p"/recipes")

    #   assert index_live |> element("#recipes-#{recipe.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#recipes-#{recipe.id}")
    # end
  end

  describe "Show" do
    setup [:create_recipe]

    test "displays recipe", %{conn: conn, recipe: recipe} do
      {:ok, _show_live, html} = live(conn, ~p"/recipes/#{recipe}")

      assert html =~ "Show Recipe"
      assert html =~ recipe.title
    end
  end
end
