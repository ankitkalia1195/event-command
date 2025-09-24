import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.selectedRating = 0
    this.setupFormValidation()
  }

  select(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.selectedRating = rating
    console.log('Rating selected:', rating)
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
      console.log('Setting input value to:', this.selectedRating, 'Actual value:', this.inputTarget.value)
      // Trigger multiple events to ensure the value is properly set
      this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }))
      this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
      
      // Also set the value directly on the element
      this.inputTarget.setAttribute('value', this.selectedRating)
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
