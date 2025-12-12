defmodule IronfolkCombatWeb.Components.InfoCard do
  use Phoenix.Component

  attr(:icon, :string, required: true, doc: "SVG path data for icon")
  attr(:title, :string, required: true)
  attr(:description, :string, required: true)
  attr(:link_text, :string, default: nil)
  attr(:link_path, :string, default: nil)
  slot(:details, doc: "Additional details content")

  def info_card(assigns) do
    ~H"""
    <div class="bg-white dark:bg-grey-800 rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300">
      <div class="p-6 space-y-4">
        <div class="w-16 h-16 bg-pink-100 dark:bg-pink-900/30 rounded-full flex items-center justify-center mx-auto">
          <svg
            class="w-8 h-8 text-pink-600 dark:text-pink-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={@icon}></path>
          </svg>
        </div>

        <h3 class="text-xl font-semibold text-gray-900">{@title}</h3>

        <p class="text-gray-600">{@description}</p>

        <%= if @details != [] do %>
          <div class="pt-2 border-t border-gray-200 dark:border-gray-700 space-y-1">
            {render_slot(@details)}
          </div>
        <% end %>

        <%= if @link_text && @link_path do %>
          <div class="pt-2 border-t border-gray-200 dark:border-gray-700">
            <.link
              navigate={@link_path}
              class="text-sm text-pink-600 dark:text-pink-400 hover:text-pink-700 dark:hover:text-pink-300 font-medium transition-colors"
            >
              {@link_text} →
            </.link>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
