defmodule App.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Recipes.Recipe

  @recipes_path Path.join([:code.priv_dir(:app), "static", "recipes"])

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

  @doc """
  Returns the list of recipes from files.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    File.ls!(@recipes_path)
    |> Task.async_stream(&get_recipe_from_file!/1, max_concurrency: 10)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, value} -> value end)
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(123)
      %Recipe{}

      iex> get_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(id), do: Repo.get!(Recipe, id)

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(attrs) do
    %Recipe{}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a recipe.

  ## Examples

      iex> delete_recipe(recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(%Recipe{} = recipe) do
    Repo.delete(recipe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end

  @doc """
  Searches for recipes based on a query.

  ## Examples

      iex> search_recipes("query")
      [%Recipe{}, ...]

  """
  def search_recipes(query) do
    # TODO: Use GenServer to read recipes once
    recipes = list_recipes()
    query_downcase = String.downcase(query)

    Enum.filter(recipes, fn recipe ->
      String.contains?(String.downcase(recipe.title), query_downcase)
    end)
  end
end
