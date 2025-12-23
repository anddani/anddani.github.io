defmodule AppWeb.RecipeLive.Show do
  use AppWeb, :live_view

  alias App.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Recipe {@recipe.title}
        <:actions>
          <.button navigate={~p"/recipes"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
        <:subtitle>This is a recipe record from your database.</:subtitle>
      </.header>

      <.list>
        <:item title="Ingredients">{@recipe.ingredients}</:item>
        <:item title="Instructions">{@recipe.instructions}</:item>
        <:item title="Tags">{@recipe.tags}</:item>
        <:item title="Image url">{@recipe.image_url}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    dbg(Recipes.get_recipe_by_slug(id))

    {:ok,
     socket
     |> assign(:page_title, "Show Recipe")
     |> assign(:recipe, Recipes.get_recipe_by_slug(id))}
  end
end
