import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ratingInput"]

  connect() {
    this.setupFormSubmission()
  }

  setupFormSubmission() {
    // Find the rating controller within this form
    const ratingController = this.element.querySelector('[data-controller*="rating"]')
    if (ratingController) {
      // Get the rating controller instance
      const ratingInstance = this.application.getControllerForElementAndIdentifier(ratingController, 'rating')
      
      if (ratingInstance) {
        // Override the form submission to ensure rating is set
        this.element.addEventListener('submit', (event) => {
          // Ensure rating is set before submission
          if (ratingInstance.selectedRating > 0) {
            ratingInstance.updateInput()
            
            // Double-check the input value
            if (this.hasRatingInputTarget) {
              this.ratingInputTarget.value = ratingInstance.selectedRating
            }
          } else {
            event.preventDefault()
            alert('Please select a rating before submitting.')
            return false
          }
        })
      }
    }
  }
}
