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

      <div class="mx-auto max-w-2xl mt-20 flex flex-col space-y-8 bg-white p-8 shadow-sm">
        <.form for={%{}} as={:search} phx-change="search" phx-submit="search">
          <.input
            type="search"
            class="w-full border border-gray-100 text-2xl active:border-0 active:border-gray-200 focus:border-gray-200 focus:ring-0 bg-gray-50"
            value={@q}
            name="query"
            placeholder="Search..."
          />
        </.form>
        <div class="flex flex-col space-y-8">
          <div :for={recipe <- @recipes} class="flex flex-col space-y-1">
            <h2 class="text-2xl font-medium text-gray-900">
              {recipe.title}
            </h2>
          </div>
        </div>
      </div>

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
    dbg("MOUNTING")

    {:ok,
     socket
     |> assign(:page_title, "Listing Recipes")
     |> assign(:recipes, [])
     |> assign(:q, "")
     |> stream(:recipes, list_recipes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(id)
    {:ok, _} = Recipes.delete_recipe(recipe)

    {:noreply, stream_delete(socket, :recipes, recipe)}
  end

  @impl true
  def handle_event("search", %{"query" => q}, socket) do
    recipes =
      q
      |> App.Recipes.search_recipes()

    dbg("Recipes found: #{inspect(recipes)}")

    {:noreply, assign(socket, :recipes, recipes)}
  end

  defp list_recipes() do
    Recipes.list_recipes()
  end
end
