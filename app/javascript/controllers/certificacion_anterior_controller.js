import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["toggleable"]

    connect() {
        this.toggleFields() // Set initial state based on the default radio button
    }

    toggleFields() {
        const shouldShowFields = this.element.querySelector('input[type="radio"][value="Si"]').checked;
        this.toggleableTargets.forEach((el) => {
            el.style.display = shouldShowFields ? 'block' : 'none';
        });
    }
}
