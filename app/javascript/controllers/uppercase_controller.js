// app/javascript/controllers/uppercase_controller.js
import { Controller } from "@hotwired/stimulus"

//cada letra con mayuscula

export default class extends Controller {
    static targets = ["input"]

    connect() {
        this.element.addEventListener('input', this.capitalize.bind(this));
    }

    capitalize() {
        this.inputTarget.value = this.inputTarget.value.toUpperCase();
    }
}
