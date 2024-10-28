// app/javascript/controllers/titleize_controller.js

//inicio y despues de cada espacio en blanco con mayuscula

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"];

    titleize(text) {
        return text.replace(/(^|\s)([^\s])/g, (match, p1, p2) => p1 + p2.toUpperCase());
    }


    updateInput(event) {
        this.inputTarget.value = this.titleize(event.target.value);
    }
}
