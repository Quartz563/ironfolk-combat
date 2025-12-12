defmodule IronfolkCombatWeb.Components.Navigation do
  use Phoenix.Component
  import IronfolkCombatWeb.CoreComponents
  alias Phoenix.LiveView.JS
  use IronfolkCombatWeb, :verified_routes

  attr :current_path, :string, default: ""

  def navigation(assigns) do
    ~H"""
    <header class="sticky top-0 left-0 right-0 bg-white dark:bg-gray-900 border-b-2 border-pink-200 dark:border-pink-800 z-50">
      <div class="w-full px-4">
        <div class="flex items-stretch justify-between h-20">
          <!-- Mobile menu button (show below xl breakpoint) -->
          <button
            type="button"
            class="xl:hidden text-gray-700 dark:text-gray-200 hover:text-pink-600 p-2 flex items-center"
            phx-click={JS.toggle(to: "#mobile-menu") |> JS.toggle_class("hidden", to: "#mobile-menu")}
            aria-label="Toggle menu"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16M4 18h16"
              >
              </path>
            </svg>
          </button>
          
    <!-- Desktop Navigation (show at xl and above) - spans full width -->
          <nav class="hidden xl:flex items-stretch h-full flex-1 justify-between max-w-screen-2xl mx-auto">
            <!-- Left side nav items -->
            <div class="flex items-stretch">
              <.nav_link href={~p"/about"} current={@current_path == "/about"}>About</.nav_link>
              <.nav_link href={~p"/contact"} current={@current_path == "/contact"}>Contact</.nav_link>
              <.nav_link href={~p"/events"} current={@current_path == "/events"}>Events</.nav_link>
            </div>
            
    <!-- Logo in center -->
            <.link navigate={~p"/"} class="flex items-center justify-center px-8">
              <img src={~p"/images/ironfolk-logo.svg"} alt="Ironfolk Combat" class="h-12 w-auto" />
            </.link>
            
    <!-- Right side nav items -->
            <div class="flex items-stretch">
              <!--<.nav_link href={~p"/payment"} current={@current_path == "/payment"}>Fees</.nav_link>-->
              <.nav_link href={~p"/resources"} current={@current_path == "/resources"}>
                Resources
              </.nav_link>
              <.nav_link href={~p"/blog"} current={@current_path == "/blog"}>Blog</.nav_link>
              
    <!-- Desktop CTA Button -->
              <div class="flex items-center self-center ml-4">
                <.link navigate={~p"/signup"} class="rainbow-button">
                  Join Us
                </.link>
              </div>
            </div>
          </nav>
          
    <!-- Mobile logo (center, visible below xl) -->
          <.link
            navigate={~p"/"}
            class="xl:hidden flex items-center absolute left-1/2 transform -translate-x-1/2"
          >
            <img src={~p"/images/ironfolk-logo.svg"} alt="Ironfolk Combat" class="ph-5 h-16 w-auto" />
          </.link>
          
    <!-- Spacer for mobile -->
          <div class="xl:hidden w-10"></div>
        </div>
        
    <!-- Mobile Menu Dropdown (show below xl) -->
        <nav
          id="mobile-menu"
          class="hidden xl:!hidden pb-4 border-t border-pink-200 dark:border-pink-800"
          phx-click-away={JS.add_class("hidden", to: "#mobile-menu")}
        >
          <div class="flex flex-col">
            <.mobile_nav_link href={~p"/about"} current={@current_path == "/about"}>
              About
            </.mobile_nav_link>
            <.mobile_nav_link href={~p"/contact"} current={@current_path == "/contact"}>
              Contact
            </.mobile_nav_link>
            <.mobile_nav_link href={~p"/events"} current={@current_path == "/events"}>
              Events
            </.mobile_nav_link>
            <!--<.mobile_nav_link href={~p"/payment"} current={@current_path == "/payment"}>
              Fees
            </.mobile_nav_link>-->
            <.mobile_nav_link href={~p"/resources"} current={@current_path == "/resources"}>
              Resources
            </.mobile_nav_link>
            <.mobile_nav_link href={~p"/blog"} current={@current_path == "/blog"}>
              Blog
            </.mobile_nav_link>
            
    <!-- Mobile CTA Button -->
            <div class="mt-4 pt-4 border-t border-pink-200 dark:border-pink-800 flex justify-center">
              <.link navigate={~p"/signup"} class="rainbow-button">
                Join Us
              </.link>
            </div>
          </div>
        </nav>
      </div>
    </header>
    """
  end

  # Desktop navigation link - now uses CSS class
  attr :href, :string, required: true
  attr :current, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "nav-link dark:text-gray-200",
        if(@current, do: "text-pink-600 dark:text-pink-400", else: "")
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  # Mobile navigation link - now uses CSS class
  attr :href, :string, required: true
  attr :current, :boolean, default: false
  slot :inner_block, required: true

  defp mobile_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "mobile-nav-link dark:text-gray-200",
        if(@current, do: "text-pink-600 dark:text-pink-400", else: "")
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
