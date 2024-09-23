// app/javascript/controllers/confirm_navigation_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    confirmExit(event) {
        event.preventDefault(); // Previene la navegación inmediata

        const href = this.element.getAttribute("href"); // Obtiene el URL del enlace

        Swal.fire({
            title: "¿Estás seguro?",
            text: "¡No podrás revertir esta acción!",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Sí, salir",
            cancelButtonText: "Cancelar",
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                // Navega al enlace si se confirma
                window.location.href = href;
            }
        });
    }
}
