// app/javascript/controllers/logout_confirmation_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    static values = { redirectUrl: String }

    deleteSession(event) {
        event.preventDefault(); // Evita la acción predeterminada de seguir el enlace

        const href = this.element.getAttribute("href"); // Obtiene el URL del enlace
        const redirectUrl = this.redirectUrlValue || "/"; // URL de redirección o valor por defecto

        Swal.fire({
            title: "¿Confirmar cierre de sesión?",
            showCancelButton: true,
            confirmButtonText: "Cerrar sesión",
            cancelButtonText: "Cancelar",
            icon: "info",
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                fetch(href, {
                    method: "DELETE",
                    headers: {
                        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
                        "Accept": "text/vnd.turbo-stream.html"
                    },
                    credentials: "include"
                })
                    .then(response => {
                        if (response.ok) {
                            Swal.fire({
                                title: "Sesión cerrada.",
                                icon: "success"
                            }).then(() => {
                                // Redirige solo si la eliminación fue exitosa
                                window.location.href = redirectUrl;
                            });
                        } else {
                            Swal.fire({
                                title: "Error",
                                text: "No se pudo cerrar sesión.",
                                icon: "error"
                            });
                        }
                    });
            }
        });
    }
}
