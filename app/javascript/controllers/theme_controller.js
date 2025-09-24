import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sunIcon", "moonIcon"]

  connect() {
    // Initialize theme from localStorage or default to dark
    const savedTheme = localStorage.getItem('theme') || 'dark'
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = document.documentElement.classList.contains('dark') ? 'dark' : 'light'
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    const html = document.documentElement
    const sunIcon = document.getElementById('sun-icon')
    const moonIcon = document.getElementById('moon-icon')

    if (theme === 'dark') {
      html.classList.add('dark')
      html.classList.remove('light')
      html.setAttribute('data-theme', 'dark')
      if (sunIcon) sunIcon.classList.remove('hidden')
      if (moonIcon) moonIcon.classList.add('hidden')
    } else {
      html.classList.add('light')
      html.classList.remove('dark')
      html.setAttribute('data-theme', 'light')
      if (sunIcon) sunIcon.classList.add('hidden')
      if (moonIcon) moonIcon.classList.remove('hidden')
    }

    // Save theme preference
    localStorage.setItem('theme', theme)
  }
}
