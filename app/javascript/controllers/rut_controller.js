// app/javascript/controllers/rut_controller.js
import { Controller } from "@hotwired/stimulus"

//controlador para añadir un guion antes del final del rut
export default class extends Controller {
    static targets = ["rut"];

    connect() {
        this.formatRut();
    }

    formatRut() {
        const input = this.rutTarget;
        input.addEventListener("input", (e) => {
            let value = e.target.value.replace(/[^0-9kK]+/g, '').toUpperCase(); // Remove invalid characters and convert to uppercase
            value = value.replace(/\./g, '').replace(/-/g, '');
            if (value.length > 1) {
                value = value.slice(0, -1) + "-" + value.slice(-1);
            }
            const parts = value.split("-");
            let numberPart = parts[0];
            numberPart = numberPart.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
            value = numberPart + (parts[1] ? "-" + parts[1] : "");
            e.target.value = value;
        });
    }
}