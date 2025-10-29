defmodule AppWeb.RecipeLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.RecipesFixtures

  @create_attrs %{
    instructions: "some instructions",
    title: "some title",
    slug: "some slug",
    ingredients: ["option1", "option2"],
    tags: ["option1", "option2"],
    image_url: "some image_url"
  }
  @update_attrs %{
    instructions: "some updated instructions",
    title: "some updated title",
    slug: "some updated slug",
    ingredients: ["option1"],
    tags: ["option1"],
    image_url: "some updated image_url"
  }
  @invalid_attrs %{
    instructions: nil,
    title: nil,
    slug: nil,
    ingredients: [],
    tags: [],
    image_url: nil
  }
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

    test "saves new recipe", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Recipe")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/new")

      assert render(form_live) =~ "New Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes")

      html = render(index_live)
      assert html =~ "Recipe created successfully"
      assert html =~ "some title"
    end

    test "updates recipe in listing", %{conn: conn, recipe: recipe} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#recipes-#{recipe.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}/edit")

      assert render(form_live) =~ "Edit Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes")

      html = render(index_live)
      assert html =~ "Recipe updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes recipe in listing", %{conn: conn, recipe: recipe} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert index_live |> element("#recipes-#{recipe.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#recipes-#{recipe.id}")
    end
  end

  describe "Show" do
    setup [:create_recipe]

    test "displays recipe", %{conn: conn, recipe: recipe} do
      {:ok, _show_live, html} = live(conn, ~p"/recipes/#{recipe}")

      assert html =~ "Show Recipe"
      assert html =~ recipe.title
    end

    test "updates recipe and returns to show", %{conn: conn, recipe: recipe} do
      {:ok, show_live, _html} = live(conn, ~p"/recipes/#{recipe}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}/edit?return_to=show")

      assert render(form_live) =~ "Edit Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}")

      html = render(show_live)
      assert html =~ "Recipe updated successfully"
      assert html =~ "some updated title"
    end
  end
end
