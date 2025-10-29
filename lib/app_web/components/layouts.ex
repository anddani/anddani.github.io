defmodule AppWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AppWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates("layouts/*")

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
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
    ~H"""
    <canvas
      id="canvas"
      class="bg-black fixed z-[-1] top-0 left-0"
      phx-update="ignore"
    >
      Your browser does not support the HTML5 canvas tag.
    </canvas>

    <div class="flex flex-col h-screen max-w-dvw">
      <header class="w-full px-4 pt-3 pb-6 sm:px-6 lg:px-8 bg-transparent border-b-gray-600 border-b-2">
        <a href={~p"/"}>
          <h1 class="text-[42px]">Welcome!</h1>
        </a>
      </header>

      <div class="flex flex-row min-h-0 h-full">
        <nav class="p-4 border-r-gray-600 border-r-2 shrink-0">
          <ul class="flex flex-col gap-2">
            <li><ButtonLayouts.recipes /></li>
            <li><ButtonLayouts.sakelog /></li>
          </ul>
        </nav>

        <main class="px-4 grow overflow-y-auto">
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
