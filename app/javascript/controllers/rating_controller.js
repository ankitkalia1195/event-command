import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.selectedRating = 0
    this.initializeRating()
    this.setupFormValidation()
  }

  initializeRating() {
    // Check if there's already a rating value in the input
    if (this.hasInputTarget && this.inputTarget.value) {
      this.selectedRating = parseInt(this.inputTarget.value)
      this.updateStars()
    }
  }

  select(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.selectedRating = rating
    this.updateStars()
    this.updateInput()
  }

  updateStars() {
    this.starTargets.forEach((star, index) => {
      const starRating = index + 1
      if (starRating <= this.selectedRating) {
        star.classList.remove("text-gray-400")
        star.classList.add("text-yellow-400")
        star.setAttribute("aria-checked", "true")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-400")
        star.setAttribute("aria-checked", "false")
      }
    })
  }

  updateInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = this.selectedRating
      
      // Set the value attribute as well
      this.inputTarget.setAttribute('value', this.selectedRating)
      
      // Trigger multiple events to ensure the value is properly set
      this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }))
      this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
      
      // Force a form validation update
      if (this.inputTarget.form) {
        this.inputTarget.form.dispatchEvent(new Event('input', { bubbles: true }))
      }
    }
  }

  setupFormValidation() {
    // Find the form and add validation
    const form = this.element.closest('form')
    if (form) {
      // Handle submit button clicks
      const submitButton = form.querySelector('input[type="submit"], button[type="submit"]')
      if (submitButton) {
        submitButton.addEventListener('click', (event) => {
          // Ensure rating is set before submission
          this.updateInput()
          
          if (this.selectedRating === 0) {
            event.preventDefault()
            alert('Please select a rating before submitting.')
            return false
          }
        })
      }
      
      // Handle form submission
      form.addEventListener('submit', (event) => {
        // Ensure rating is set before submission
        this.updateInput()
        
        if (this.selectedRating === 0) {
          event.preventDefault()
          alert('Please select a rating before submitting.')
          return false
        }
        
        // Double-check that the input has the correct value
        if (this.hasInputTarget && this.inputTarget.value === '') {
          event.preventDefault()
          alert('Please select a rating before submitting.')
          return false
        }
      })
    }
  }
}
