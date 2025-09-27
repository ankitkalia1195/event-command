import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
// This controller is kept for potential future use but the current layout uses mobile-dropdown
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Initialize mobile menu state
    this.isOpen = false
  }

  toggle() {
    // This method is not currently used as the layout uses mobile-dropdown controller
    // Keeping this for potential future use
    console.log("Mobile menu toggle called - but layout uses mobile-dropdown controller")
  }

  // Close menu when clicking outside (optional enhancement)
  disconnect() {
    // Cleanup if needed
  }
}
