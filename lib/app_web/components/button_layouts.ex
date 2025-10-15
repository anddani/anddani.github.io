defmodule AppWeb.ButtonLayouts do
  use Phoenix.Component
  alias AppWeb.Surfaces

  use AppWeb, :verified_routes

  def recipes(assigns) do
    ~H"""
    <.button_frame text="Recipes" href={~p"/recipes"} img_src={~p"/images/tokkuri.png"} />
    """
  end

  def sakelog(assigns) do
    ~H"""
    <.button_frame text="Sakelog" href={~p"/sakelog"} img_src={~p"/images/tokkuri.png"} />
    """
  end

  attr(:href, :string, required: true)
  attr(:text, :string, required: true)
  attr(:img_src, :string, required: true)

  defp button_frame(assigns) do
    ~H"""
    <.link href={@href}>
      <Surfaces.frame clickable class="pr-4 py-1">
        <div class="inline-flex gap-2 items-center justify-center">
          <img class="size-12" src={@img_src} />
          <span>{@text}</span>
        </div>
      </Surfaces.frame>
    </.link>
    """
  end
end
