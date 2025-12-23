defmodule App.Recipes.Cache do
  @moduledoc """
  GenServer that caches recipes in memory.

  Reads all recipe YAML files on startup and stores them in memory.
  """

  use GenServer

  alias App.Recipes.Recipe

  @recipes_path Path.join([:code.priv_dir(:app), "static", "recipes"])

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns all cached recipes.
  """
  def list_recipes do
    GenServer.call(__MODULE__, :list_recipes)
  end

  @doc """
  Returns a recipe by slug, or nil if not found.
  """
  def get_by_slug(slug) do
    GenServer.call(__MODULE__, {:get_by_slug, slug})
  end

  @doc """
  Reloads all recipes from disk.
  """
  def reload do
    GenServer.call(__MODULE__, :reload)
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    recipes = load_recipes()
    {:ok, %{recipes: recipes}}
  end

  @impl true
  def handle_call(:list_recipes, _from, state) do
    {:reply, state.recipes, state}
  end

  @impl true
  def handle_call({:get_by_slug, slug}, _from, state) do
    recipe = Enum.find(state.recipes, fn r -> r.slug == slug end)
    {:reply, recipe, state}
  end

  @impl true
  def handle_call(:reload, _from, _state) do
    recipes = load_recipes()
    {:reply, :ok, %{recipes: recipes}}
  end

  # Private functions

  defp load_recipes do
    File.ls!(@recipes_path)
    |> Task.async_stream(&get_recipe_from_file!/1, max_concurrency: 10, timeout: :infinity)
    |> Enum.map(fn {:ok, value} -> value end)
  end

  defp get_recipe_from_file!(recipe_filename) do
    slug = Path.basename(recipe_filename, ".yaml")
    recipe_path = Path.join(@recipes_path, recipe_filename)

    recipe_attrs =
      YamlElixir.read_from_file!(recipe_path, atoms: true)
      |> Map.put(:slug, slug)

    validated =
      %Recipe{}
      |> Recipe.changeset(recipe_attrs)
      |> Ecto.Changeset.apply_action(:validate)

    case validated do
      {:ok, recipe} ->
        recipe

      {:error, changeset} ->
        raise "Invalid recipe #{recipe_filename}: #{inspect(changeset.errors)}"
    end
  end
end
