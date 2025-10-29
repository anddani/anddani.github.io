defmodule AppWeb.RecipeLive.Index do
  use AppWeb, :live_view

  alias App.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Recipes
        <:actions>
          <.button variant="primary" navigate={~p"/recipes/new"}>
            <.icon name="hero-plus" /> New Recipe
          </.button>
        </:actions>
      </.header>

      <.table
        id="recipes"
        rows={@streams.recipes}
        row_click={fn {_id, recipe} -> JS.navigate(~p"/recipes/#{recipe}") end}
      >
        <:col :let={{_id, recipe}} label="Title">{recipe.title}</:col>
        <:col :let={{_id, recipe}} label="Slug">{recipe.slug}</:col>
        <:col :let={{_id, recipe}} label="Ingredients">{recipe.ingredients}</:col>
        <:col :let={{_id, recipe}} label="Instructions">{recipe.instructions}</:col>
        <:col :let={{_id, recipe}} label="Tags">{recipe.tags}</:col>
        <:col :let={{_id, recipe}} label="Image url">{recipe.image_url}</:col>
        <:action :let={{_id, recipe}}>
          <div class="sr-only">
            <.link navigate={~p"/recipes/#{recipe}"}>Show</.link>
          </div>
          <.link navigate={~p"/recipes/#{recipe}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, recipe}}>
          <.link
            phx-click={JS.push("delete", value: %{id: recipe.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Recipes")
     |> stream(:recipes, list_recipes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(id)
    {:ok, _} = Recipes.delete_recipe(recipe)

    {:noreply, stream_delete(socket, :recipes, recipe)}
  end

  defp list_recipes() do
    Recipes.list_recipes()
  end
end
