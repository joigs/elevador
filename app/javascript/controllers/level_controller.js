// app/javascript/controllers/level_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
    static targets = ["field", "label"]

    connect() {
        // Set initial value based on the hidden field if needed
        this.labelTarget.textContent = this.fieldTarget.value;
    }

    toggleValue() {
        const currentValue = this.labelTarget.textContent;
        const newValue = currentValue === "G" ? "L" : "G";
        this.labelTarget.textContent = newValue;
        this.fieldTarget.value = newValue;
    }
}
