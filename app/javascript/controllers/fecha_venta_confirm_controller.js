// app/javascript/controllers/fecha_venta_confirm_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
    static values = { url: String }

    confirm () {
        Swal.fire({
            title: "¿Asignar la fecha de venta a hoy?",
            icon: "question",
            showCancelButton: true,
            confirmButtonText: "Sí, asignar",
            cancelButtonText: "Cancelar",
            customClass: {
                confirmButton: 'mr-10'
            }        }).then(result => {
            if (result.isConfirmed) this.updateFechaVenta()
        })
    }

    async updateFechaVenta () {
        const csrfToken = document.querySelector("meta[name='csrf-token']").content

        const response = await fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "X-CSRF-Token": csrfToken,
                "Accept": "application/json"
            },
            credentials: "same-origin"
        })

        if (response.ok) {
            Swal.fire({ icon: "success", title: "Actualizado", text: "La fecha de venta se fijó correctamente." })
                .then(() => window.location.reload())
        } else {
            Swal.fire({ icon: "error", title: "Error", text: "No se pudo actualizar la fecha." })
        }
    }
}
