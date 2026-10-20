import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["noImplementado", "na"]

  exclusive(event) {
    if (!event.target.checked) return

    if (event.target === this.noImplementadoTarget) {
      this.naTarget.checked = false
    } else {
      this.noImplementadoTarget.checked = false
    }
  }
}
