import { Controller } from "@hotwired/stimulus"

// Controller to manage form elements based on the state of 'past_fail' checkboxes.
export default class PastSubmitController extends Controller {
    static targets = ["checkbox", "code", "point", "level"]

    connect() {
        // Initialize form fields state based on current checkbox states.
        this.toggleSubmit();
    }

    toggleSubmit(event) {
        // Adjust form fields whenever a checkbox state changes.
        this.checkboxTargets.forEach((checkbox, index) => {
            const isEnabled = checkbox.checked;
            const codeInput = this.codeTargets[index];
            const pointInput = this.pointTargets[index];
            const levelInput = this.levelTargets[index];

            // Enable or disable fields based on checkbox state.
            codeInput.disabled = !isEnabled;
            pointInput.disabled = !isEnabled;
            levelInput.disabled = !isEnabled;
        });
    }
}
