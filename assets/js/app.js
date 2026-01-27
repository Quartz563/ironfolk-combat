// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

// Scroll hook for code of conduct and other policy
let Hooks = {};

Hooks.ScrollDetector = {
  mounted() {
    const element = this.el;
    const event = element.dataset.event;

    element.addEventListener("scroll", () => {
      // Check if scrolled to bottom (with 10px tolerance)
      const isAtBottom =
        element.scrollHeight - element.scrollTop - element.clientHeight < 10;

      if (isAtBottom) {
        this.pushEvent(event, {});
        // Remove listener after first trigger
        element.removeEventListener("scroll", this.handleScroll);
      }
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Mobile menu functionality
function initMobileMenu() {
  const mobileMenuButton = document.getElementById("mobile-menu-button");
  const mobileSidebar = document.getElementById("mobile-sidebar");
  const closeSidebar = document.getElementById("close-sidebar");

  if (mobileMenuButton && mobileSidebar) {
    mobileMenuButton.addEventListener("click", function (e) {
      e.preventDefault();
      mobileSidebar.classList.remove("hidden");
    });
  }

  if (closeSidebar && mobileSidebar) {
    closeSidebar.addEventListener("click", function (e) {
      e.preventDefault();
      mobileSidebar.classList.add("hidden");
    });
  }

  if (mobileSidebar) {
    mobileSidebar.addEventListener("click", function (e) {
      if (e.target === mobileSidebar) {
        mobileSidebar.classList.add("hidden");
      }
    });
  }
}

const MarkdownEditor = {
  mounted() {
    this.handleEvent("insert-markdown", ({ before, after, placeholder }) => {
      const editor = this.el;
      const start = editor.selectionStart;
      const end = editor.selectionEnd;
      const selectedText = editor.value.substring(start, end);
      const textToInsert = selectedText || placeholder;

      const newText = before + textToInsert + after;

      editor.value =
        editor.value.substring(0, start) +
        newText +
        editor.value.substring(end);

      // Trigger change event for LiveView
      editor.dispatchEvent(new Event("input", { bubbles: true }));

      // Set cursor position
      const newCursorPos = start + before.length + textToInsert.length;
      editor.focus();
      editor.setSelectionRange(newCursorPos, newCursorPos);
    });
  },
};

// Find where your LiveSocket is created and add the hook
Hooks.MarkdownEditor = MarkdownEditor;

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", function () {
  initMobileMenu();
});
