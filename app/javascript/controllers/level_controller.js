import { Controller } from "@hotwired/stimulus"


//controlador para manejar el caso de que el inspector asigna el nivel de importancia

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
