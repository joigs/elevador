// app/javascript/controllers/titleize_controller.js

//inicio y despues de cada espacio en blanco con mayuscula

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"];

    titleize(text) {
        return text.replace(/\b\w/g, char => char.toUpperCase());
    }

    updateInput(event) {
        this.inputTarget.value = this.titleize(event.target.value);
    }
}
