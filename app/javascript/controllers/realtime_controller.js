import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sessionStatus", "checkInStats"]
  
  connect() {
    // Update session status every 30 seconds
    this.sessionUpdateInterval = setInterval(() => {
      this.updateSessionStatus()
    }, 30000)

    // Update check-in stats every 60 seconds
    this.statsUpdateInterval = setInterval(() => {
      this.updateCheckInStats()
    }, 60000)
  }

  disconnect() {
    if (this.sessionUpdateInterval) {
      clearInterval(this.sessionUpdateInterval)
    }
    if (this.statsUpdateInterval) {
      clearInterval(this.statsUpdateInterval)
    }
  }

  updateSessionStatus() {
    // Fetch updated session status
    fetch('/agenda/session_status', {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Update the session status element
      if (this.hasSessionStatusTarget) {
        this.sessionStatusTarget.innerHTML = html
      }
    })
    .catch(error => {
      console.log('Session status update failed:', error)
    })
  }

  updateCheckInStats() {
    // Fetch updated check-in stats
    fetch('/agenda/check_in_stats', {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Update the check-in stats element
      if (this.hasCheckInStatsTarget) {
        this.checkInStatsTarget.innerHTML = html
      }
    })
    .catch(error => {
      console.log('Check-in stats update failed:', error)
    })
  }
}
