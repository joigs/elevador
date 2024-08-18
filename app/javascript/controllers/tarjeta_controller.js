import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["inspectionNumber"]

    connect() {
        this.toggleCard() // Set initial state based on the default radio button
    }

    toggleCard() {
        const isSistemaSelected = this.element.querySelector('input[type="radio"][value="sistema"]').checked;
        this.inspectionNumberTarget.style.display = isSistemaSelected ? 'block' : 'none';
    }
}
