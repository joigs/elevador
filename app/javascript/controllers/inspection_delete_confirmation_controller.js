// app/javascript/controllers/inspection_delete_confirmation_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    static values = { redirectUrl: String }

    deleteItem(event) {
        event.preventDefault();
        event.stopImmediatePropagation(); // Detiene cualquier otro controlador de eventos

        const href = this.element.getAttribute("href");
        const redirectUrl = this.redirectUrlValue || "/";

        Swal.fire({
            title: "¿Estás seguro?",
            text: "¡No podrás revertir esta acción!",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#d33",
            cancelButtonColor: "#6c757d",
            confirmButtonText: "Eliminar",
            cancelButtonText: "Cancelar",
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                fetch(href, {
                    method: "DELETE",
                    headers: {
                        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
                        "Accept": "application/json"
                    },
                    credentials: "include"
                })
                    .then(response => response.json().then(data => ({ status: response.status, ok: response.ok, data })))
                    .then(({ status, ok, data }) => {
                        if (ok) {
                            Swal.fire({
                                title: "Eliminado",
                                text: data.message || "El registro ha sido eliminado.",
                                icon: "success"
                            }).then(() => {
                                window.location.href = redirectUrl;
                            });
                        } else {
                            Swal.fire({
                                title: "Error",
                                text: data.error || "No se pudo eliminar el registro.",
                                icon: "error"
                            });
                        }
                    });
            }
        });
    }
}
