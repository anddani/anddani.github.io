defmodule AppWeb.Surfaces do
  use Phoenix.Component

  use AppWeb, :verified_routes

  @doc """
  Wraps the content in a frame.

  ## Examples

      <.frame>
        This text will be displayed inside a frame
      </.frame>

      <.link href={~p"/"}>
        <.frame clickable>
          Click me!
        </.frame>
      </.link>
  """
  attr(:clickable, :boolean, default: false, doc: "make frame indent when clicked")
  attr(:class, :string, default: "")
  slot(:inner_block, required: true)

  def frame(assigns) do
    ~H"""
    <div class={[
      "border-2 border-2",
      "border-b-gray-600 border-r-gray-600 border-l-gray-300 border-t-gray-300 bg-white/15",
      @clickable &&
        "active:bg-white/20 active:border-b-gray-300 active:border-r-gray-300 active:border-l-gray-600 active:border-t-gray-600",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
