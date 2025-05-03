//javascript/controllers/tarjeta_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["inspectionNumber"]

    connect() {
        this.toggleCard() // Set initial state based on the default radio button
    }

    toggleCard() {
        const sistemaRadio = this.element.querySelector('input[type="radio"][value="sistema"]');
        if (!sistemaRadio) {
            // Optionally hide the inspection card if the radio is not present
            this.inspectionNumberTarget.style.display = 'none';
            return;
        }
        const isSistemaSelected = sistemaRadio.checked;
        this.inspectionNumberTarget.style.display = isSistemaSelected ? 'block' : 'none';
    }

}
