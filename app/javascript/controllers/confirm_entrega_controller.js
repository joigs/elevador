import { Controller } from "@hotwired/stimulus";
import Swal from "sweetalert2";

export default class extends Controller {
    static values = { url: String };

    confirmEntrega() {
        Swal.fire({
            title: "¿Estás seguro?",
            text: "Marcarás esta facturación como entregada. No podrás deshacer esta acción.",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Sí, marcar como entregado",
            cancelButtonText: "Cancelar",
            customClass: {
                confirmButton: 'mr-10'  // Aplica margen a la derecha del botón de confirmación
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.marcarEntregado();
            }
        });
    }

    marcarEntregado() {
        fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            },
        })
            .then((response) => response.json())
            .then((data) => {
                if (data.success) {
                    Swal.fire("Entregado", data.message, "success").then(() => {
                        // Recargar la página para reflejar el cambio
                        location.reload();
                    });
                } else {
                    Swal.fire("Error", data.message, "error");
                }
            })
            .catch(() => {
                Swal.fire("Error", "No se pudo procesar la solicitud.", "error");
            });
    }
}
