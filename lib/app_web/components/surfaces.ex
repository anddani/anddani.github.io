defmodule AppWeb.Surfaces do
  use Phoenix.Component

  use AppWeb, :verified_routes

  @doc """
  Wraps the content in a frame.

  ## Examples

      <.frame>
        This text will be displayed inside a frame
      </.frame>
  """
  slot(:inner_block, required: true)

  def frame(assigns) do
    ~H"""
    <div class="border-b-gray-600 border-r-gray-600 border-b-2 border-r-2 border-l-gray-300 border-l-2 border-t-2 border-t-gray-300 bg-white/15 p-4">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
