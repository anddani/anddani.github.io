defmodule AppWeb.ButtonLayouts do
  use Phoenix.Component
  alias AppWeb.Surfaces

  use AppWeb, :verified_routes

  attr :href, :any

  def tokkuri(assigns) do
    ~H"""
    <.link href={@href}>
      <Surfaces.frame>
        <div class="inline-flex gap-2 items-center justify-center">
          <img class="size-12" src={~p"/images/tokkuri.png"} />
          <span>Sakelog</span>
        </div>
      </Surfaces.frame>
    </.link>
    """
  end
end
