import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-dropdown"
export default class extends Controller {
  static targets = ["menu", "arrow"]

  connect() {
    // Initialize dropdown state
    this.isOpen = false
    // Add click outside listener
    document.addEventListener('click', this.handleClickOutside)
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove('hidden')
    this.menuTarget.classList.add('block')
    this.arrowTarget.style.transform = 'rotate(180deg)'
    this.isOpen = true
    
    // Ensure dropdown stays within viewport
    this.adjustPosition()
  }

  close() {
    this.menuTarget.classList.add('hidden')
    this.menuTarget.classList.remove('block')
    this.arrowTarget.style.transform = 'rotate(0deg)'
    this.isOpen = false
  }

  adjustPosition() {
    const menu = this.menuTarget
    const button = this.element.querySelector('button')
    const buttonRect = button.getBoundingClientRect()
    const menuRect = menu.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    
    // Reset positioning
    menu.style.right = '0'
    menu.style.left = 'auto'
    menu.style.transform = 'translateX(0)'
    
    // Check if dropdown extends beyond right edge of viewport
    if (menuRect.right > viewportWidth - 16) {
      // Position from the right edge with some padding
      menu.style.right = '16px'
      menu.style.left = 'auto'
      menu.style.transform = 'translateX(0)'
    }
    
    // Check if dropdown extends beyond bottom edge of viewport
    if (menuRect.bottom > viewportHeight - 16) {
      // Position above the button instead
      menu.style.top = 'auto'
      menu.style.bottom = '100%'
      menu.style.marginTop = '0'
      menu.style.marginBottom = '8px'
    } else {
      // Reset to normal positioning
      menu.style.top = '100%'
      menu.style.bottom = 'auto'
      menu.style.marginTop = '12px'
      menu.style.marginBottom = '0'
    }
  }

  // Close dropdown when clicking outside
  handleClickOutside = (event) => {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside)
  }
}
