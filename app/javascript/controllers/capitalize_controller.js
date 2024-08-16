import { Controller } from "@hotwired/stimulus"

//primera letra con mayuscula

export default class extends Controller {
    static targets = ["input"];

    capitalizeFirstLetter() {
        this.inputTarget.value = this.capitalize(this.inputTarget.value);
    }

    capitalize(text) {
        return text.charAt(0).toUpperCase() + text.slice(1);
    }
}
