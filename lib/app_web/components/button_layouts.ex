defmodule AppWeb.ButtonLayouts do
  use Phoenix.Component

  use AppWeb, :verified_routes

  attr :href, :any

  def tokkuri(assigns) do
    ~H"""
    <a
      href={@href}
      class="flex flex-row gap-2 bg-white items-center pr-[22px]"
    >
      <img src={~p"/images/tokkuri.png"} />
      <span class="text-black">Sakelog</span>
    </a>
    """
  end
end
