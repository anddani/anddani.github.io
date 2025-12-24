defmodule AppWeb.Smt.Layouts do
  use Phoenix.Component
  alias AppWeb.Surfaces

  alias AppWeb.Smt.Buttons
  alias AppWeb.Smt.Surfaces

  alias App.Recipes.Recipe

  use AppWeb, :verified_routes

  @doc """

  ## Examples

      <Layouts.app_smt flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  attr(:current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"
  )

  slot(:inner_block, required: true)

  def app(assigns) do
    # TODO: Set font to smt font here. Not globally
    ~H"""
    <div class="fixed inset-0 z-[-1] bg-black bg-[url('/images/stars.png')] bg-no-repeat bg-top-left">
    </div>

    <div class="flex flex-col h-screen max-w-dvw">
      <header class="w-full px-4 pt-3 pb-6 sm:px-6 lg:px-8 bg-transparent border-b-gray-600 border-b-2">
        <a href={~p"/"}>
          <h1 class="text-[42px]">Welcome!</h1>
        </a>
      </header>

      <div class="flex flex-row min-h-0 h-full">
        <nav class="p-4 border-r-gray-600 border-r-2 shrink-0">
          <ul class="flex flex-col gap-2">
            <li><Buttons.recipes /></li>
            <li><Buttons.sakelog /></li>
          </ul>
        </nav>

        <main class="px-4 grow overflow-y-hidden">
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>

    <AppWeb.Layouts.flash_group flash={@flash} />
    """
  end

  def recipe_item(%{recipe: %Recipe{}} = assigns) do
    ~H"""
    <Surfaces.frame class="p-4 flex flex-col gap-2">
      <p>{@recipe.title}</p>
      <p>{@recipe.slug}</p>
      <p>{@recipe.ingredients}</p>
      <p>{@recipe.instructions}</p>
      <p>{@recipe.tags}</p>
      <p>{@recipe.image_url}</p>
      <p>{@recipe.inserted_at}</p>
    </Surfaces.frame>
    """
  end
end
