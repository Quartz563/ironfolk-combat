defmodule IronfolkCombatWeb.Footer do
  use Phoenix.Component

  use IronfolkCombatWeb, :verified_routes

  def footer(assigns) do
    ~H"""
    <footer class="bg-gray-900 text-white">
      <!-- Main footer content -->
      <div class="h-1 bg-gradient-to-r from-pink-400 to-pink-500"></div>

      <div class="container mx-auto px-4 py-12">
        <div class="grid md:grid-cols-3 gap-8">
          <!-- Club Info -->
          <div class="space-y-4">
            <div class="flex items-center space-x-2">
              <img src="/images/ironfolk-logo.svg" alt="Ironfolk Combat Logo" class="h-8 w-auto" />
            </div>

            <p class="text-gray-300 text-sm leading-relaxed">
              A safe, inclusive space for queer folks and allies to practice Historic Fencing.
            </p>

            <div class="flex space-x-4">
              <a
                href="https://www.facebook.com/groups/3645787538866107/"
                class="text-gray-400 hover:text-pink-400 transition-colors"
              >
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                </svg>
              </a>
              <a
                href="https://www.instagram.com/ironfolk_fencing/"
                class="text-gray-400 hover:text-pink-400 transition-colors"
              >
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
                </svg>
              </a>
              <a
                href="https://discord.gg/ckvdefupC3"
                class="text-gray-400 hover:text-pink-400 transition-colors"
                target="_blank"
                rel="noopener noreferrer"
              >
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515a.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0a12.64 12.64 0 0 0-.617-1.25a.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057a19.9 19.9 0 0 0 5.993 3.03a.078.078 0 0 0 .084-.028a14.09 14.09 0 0 0 1.226-1.994a.076.076 0 0 0-.041-.106a13.107 13.107 0 0 1-1.872-.892a.077.077 0 0 1-.008-.128a10.2 10.2 0 0 0 .372-.292a.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127a12.299 12.299 0 0 1-1.873.892a.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028a19.839 19.839 0 0 0 6.002-3.03a.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.956-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.955-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.946 2.418-2.157 2.418z" />
                </svg>
              </a>
            </div>
          </div>
          <!-- Training Schedule -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-pink-400">Training Times</h3>

            <div class="space-y-2 text-sm text-gray-300">
              <div class="flex justify-between">
                <span>Thursday</span> <br /><span>6:00 PM - 8:00 PM</span> <br /><span>Newtown</span>
              </div>

              <div class="flex justify-between">
                <span>Saturday</span> <br /><span>1:00 PM - 4:00 PM</span> <br /><span>Petone</span>
              </div>
            </div>

            <p class="text-xs text-gray-400">All skill levels welcome. First three weeks free!</p>
          </div>
          <!-- Contact Info -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-pink-400">Contact Us</h3>

            <div class="space-y-3 text-sm text-gray-300">
              <div class="flex items-start space-x-2">
                <svg
                  class="w-4 h-4 mt-0.5 text-pink-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                  >
                  </path>

                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                  >
                  </path>
                </svg>
                <div>
                  <p>39 Richmond Street
                    Petone
                    Lower Hutt 5012</p>
                </div>
              </div>

              <div class="flex items-center space-x-2">
                <svg
                  class="w-4 h-4 text-pink-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  >
                  </path>
                </svg>
                <span>Ironfolkcombat@gmail.com</span>
              </div>

              <div class="flex items-center space-x-2">
                <svg
                  class="w-4 h-4 text-pink-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                  >
                  </path>
                </svg>
                <span>0290 434 6446</span>
              </div>
            </div>
          </div>
          <!-- Site Navigation -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-pink-400">Quick Links</h3>

            <div class="grid grid-cols-5 gris-rows-5 gap-4">
              <.link
                navigate={~p"/"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors"
              >
                Home
              </.link>
              <.link
                navigate={~p"/about"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors"
              >
                About Us
              </.link>
              <.link
                navigate={~p"/signup"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors row-start-2"
              >
                Join the Club
              </.link>
              <.link
                navigate={~p"/contact"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors row-start-2"
              >
                Contact
              </.link>
              <.link
                navigate={~p"/blog"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors row-start-3"
              >
                Blog
              </.link>
              <.link
                navigate={~p"/faq"}
                class="block text-sm text-gray-300 hover:text-pink-400 transition-colors row-start-3"
              >
                FAQ
              </.link>
            </div>
            
    <!--<div class="pt-4 border-t border-gray-700">
              <h4 class="text-sm font-medium text-gray-400 mb-2">Resources</h4>

              <div class="space-y-1">
                <a href="#" class="block text-xs text-gray-400 hover:text-pink-400 transition-colors">
                  Link A Here
                </a>
                <a href="#" class="block text-xs text-gray-400 hover:text-pink-400 transition-colors">
                  Link B Here
                </a>
                <a href="#" class="block text-xs text-gray-400 hover:text-pink-400 transition-colors">
                  Link C Here
                </a>
              </div>
            </div>-->
          </div>
        </div>
      </div>
      <!-- Bottom bar -->
      <div class="border-t border-gray-700">
        <div class="container mx-auto px-4 py-4">
          <div class="flex flex-col md:flex-row justify-between items-center text-sm text-gray-400">
            <p>&copy; 2025 Ironfolk Combat. All rights reserved.</p>

            <div class="flex space-x-6 mt-2 md:mt-0">
              <!--<.link href="#" class="hover:text-pink-400 transition-colors">Privacy Policy</.link>
              <a href="#" class="hover:text-pink-400 transition-colors">Terms of Service</a>-->
              <.link href={~p"/code-of-conduct"} class="hover:text-pink-400 transition-colors">
                Code of Conduct
              </.link>
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
