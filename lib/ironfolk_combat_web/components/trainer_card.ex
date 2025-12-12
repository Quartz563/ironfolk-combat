defmodule IronfolkCombatWeb.Components.TrainerCard do
  use Phoenix.Component

  attr(:photo, :string, required: true, doc: "Path to trainer headshot")
  attr(:name, :string, required: true)
  slot :description
  slot :weapons

  def trainer_card(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden hover:shadow-xl transition-shadow duration-300 text-center">
      <div class="p-6 space-y-4">
        <img class="rounded-full w-32 h-32 mx-auto mb-4" src={@photo} alt={@name} />
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">{@name}</h3>

        <%= if @description != [] do %>
          <div class="border-t-2 border-pink-200 pt-6 text-gray-600">
            {render_slot(@description)}
          </div>
        <% end %>

        <%= if @weapons != [] do %>
          <div class="border-t-2 border-pink-200 pt-6 text-gray-600">
            <p class="font-medium mb-2">{@name} has experience in the following weapons:</p>
            {render_slot(@weapons)}
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
