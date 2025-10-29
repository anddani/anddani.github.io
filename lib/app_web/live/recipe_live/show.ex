defmodule AppWeb.RecipeLive.Show do
  use AppWeb, :live_view

  alias App.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Recipe {@recipe.id}
        <:subtitle>This is a recipe record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/recipes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/recipes/#{@recipe}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit recipe
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@recipe.title}</:item>
        <:item title="Slug">{@recipe.slug}</:item>
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
    {:ok,
     socket
     |> assign(:page_title, "Show Recipe")
     |> assign(:recipe, Recipes.get_recipe!(id))}
  end
end
