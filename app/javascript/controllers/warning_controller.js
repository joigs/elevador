// app/javascript/controllers/warning_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    static targets = ["button"]

    handleClick(event) {
        const insDate = this.data.get("insDate")
        const isOwner = this.data.get("isOwner") === "true"
        const control = this.data.get("control") === "true"

        // Comprueba las condiciones que deseas validar
        if (!isOwner || !control || new Date(insDate) > new Date()) {
            event.preventDefault(); // Evita la navegación
            Swal.fire({
                icon: "warning",
                title: "Advertencia",
                text: "No puedes realizar la inspección en este momento.",
                footer: "Espera al día indicado o modifica la fecha al día de hoy",
                confirmButtonText: "Entendido"
            });
        }
    }
}
