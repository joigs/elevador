// app/javascript/controllers/warning_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    handleClick(event) {
        const insDate = this.data.get("insDate");
        const isOwner = this.data.get("isOwner") === "true";
        const control = this.data.get("control") === "true";
        const lastInspectionUrl = this.data.get("lastInspectionUrl"); // Recibir la URL de la última inspección
        const href = event.currentTarget.href; // Capturar la URL del botón para redirigir después

        // Si el usuario no es el dueño
        if (!isOwner) {
            event.preventDefault(); // Evita la navegación
            Swal.fire({
                icon: "warning",
                title: "Advertencia",
                text: "No puedes realizar la inspección porque no te fue asignada.",
                confirmButtonText: "Entendido"
            });
            return;
        }

        // Si el activo tiene una inspección más reciente
        if (!control) {
            event.preventDefault(); // Evita la navegación
            Swal.fire({
                icon: "warning",
                title: "Advertencia",
                html: `No puedes realizar la inspección porque ya existe una inspección más reciente. <a href="${lastInspectionUrl}" class="text-blue-500 underline">Ver la última inspección</a>`,
                confirmButtonText: "Entendido"
            });
            return;
        }

        // Si la fecha de la inspección es posterior a hoy
        if (new Date(insDate) > new Date()) {
            event.preventDefault(); // Evita la navegación inicialmente
            Swal.fire({
                icon: "info",
                title: "Prellenado",
                text: "Solo se podrá realizar un prellenado en este momento. Para realizar la inspección, espera a la fecha programada.",
                confirmButtonText: "Continuar"
            }).then(() => {
                // Redirigir después de mostrar la alerta
                window.location.href = href;
            });
        }
    }
}
