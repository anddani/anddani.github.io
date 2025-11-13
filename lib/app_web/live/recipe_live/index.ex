defmodule AppWeb.RecipeLive.Index do
  use AppWeb, :live_view

  alias App.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col h-full">
        <.header>
          Recipes
          <:actions>
            <.button variant="primary" navigate={~p"/recipes/new"}>
              <.icon name="hero-plus" /> New Recipe
            </.button>
          </:actions>
        </.header>

        <div>
          <.form for={%{}} as={:search} phx-change="search" phx-submit="search">
            <.input
              type="search"
              value={@q}
              name="query"
              placeholder="Search..."
            />
          </.form>
        </div>

        <ul
          id="recipes"
          phx-update="stream"
          class="h-full overflow-y-auto flex flex-col gap-2 grow pb-4"
        >
          <li :for={{dom_id, recipe} <- @streams.recipes} id={dom_id}>
            <AppWeb.RecipesLayouts.recipe_item recipe={recipe} />
          </li>
        </ul>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    recipes = Recipes.list_recipes()

    {:ok,
     socket
     |> assign(:page_title, "Listing Recipes")
     |> assign(:q, "")
     |> stream(:recipes, recipes)}
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
      |> Recipes.search_recipes()

    dbg("Recipes found: #{inspect(recipes)}")

    {:noreply,
     socket
     |> stream(:recipes, recipes, reset: true)}
  end
end
