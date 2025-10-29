defmodule AppWeb.RecipeLive.Form do
  use AppWeb, :live_view

  alias App.Recipes
  alias App.Recipes.Recipe

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage recipe records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="recipe-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input
          field={@form[:ingredients]}
          type="select"
          multiple
          label="Ingredients"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input field={@form[:instructions]} type="textarea" label="Instructions" />
        <.input
          field={@form[:tags]}
          type="select"
          multiple
          label="Tags"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input field={@form[:image_url]} type="textarea" label="Image url" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Recipe</.button>
          <.button navigate={return_path(@return_to, @recipe)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id)

    socket
    |> assign(:page_title, "Edit Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(recipe)))
  end

  defp apply_action(socket, :new, _params) do
    recipe = %Recipe{}

    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(recipe)))
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset = Recipes.change_recipe(socket.assigns.recipe, recipe_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    save_recipe(socket, socket.assigns.live_action, recipe_params)
  end

  defp save_recipe(socket, :edit, recipe_params) do
    case Recipes.update_recipe(socket.assigns.recipe, recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, recipe))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_recipe(socket, :new, recipe_params) do
    case Recipes.create_recipe(recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, recipe))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _recipe), do: ~p"/recipes"
  defp return_path("show", recipe), do: ~p"/recipes/#{recipe}"
end
