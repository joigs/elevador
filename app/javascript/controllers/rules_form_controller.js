// app/javascript/controllers/rules_form_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["fail", "level", "point", "code", "photo", "photoCode"]

    connect() {
        this.toggleFields(); // Initial check in case of pre-checked boxes
        this.photoTargets.forEach((photoInput) => {
            photoInput.addEventListener('change', (event) => this.handleFileUpload(event));
        });
    }

    toggleFields() {
        this.failTargets.forEach((failTarget, index) => {
            const isChecked = failTarget.checked;
            const photoInput = this.photoTargets[index];
            const codeInput = this.codeTargets[index];
            const photoCodeInput = this.photoCodeTargets[index];
            const levelInput = this.levelTargets[index];
            const pointInput = this.pointTargets[index];



            if (isChecked) {
                photoInput.disabled = false;
                codeInput.disabled = false;
                levelInput.disabled = false;
                pointInput.disabled = false;
                console.log("b")


            } else {
                photoInput.disabled = true;
                codeInput.disabled = true;
                photoCodeInput.disabled = true;
                levelInput.disabled = true;
                pointInput.disabled = true;

            }

        });
    }

    toggle(event) {
        this.toggleFields(); // Call this method on change
    }

    handleFileUpload(event) {
        const input = event.target;
        if(input.files.length > 0) {
            const fileName = input.files[0].name;
            console.log(`File uploaded: ${fileName}`);
            // Find the index of the photo input that triggered the upload event
            const photoInputIndex = this.photoTargets.indexOf(input);
            // Assuming photoCodeInputs are in the same order as photoInputs
            const photoCodeInput = this.photoCodeTargets[photoInputIndex];
            if (photoCodeInput) {
                photoCodeInput.disabled = false; // Disable the corresponding photoCodeInput
            }
            // Perform additional actions here, such as updating the UI
        }
    }
}
