import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }
    static targets = ["detalle"]

    update(event) {
        const sucursalId = event.target.value
        if (!sucursalId) return

        const csrfToken = document.querySelector('meta[name="csrf-token"]').content

        fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({ sucursal_id: sucursalId })
        })
            .then((response) => response.ok ? response.json() : Promise.reject(response))
            .then((data) => {
                if (this.hasDetalleTarget) this.detalleTarget.textContent = data.detalle
            })
            .catch(() => {
                window.Swal.fire({
                    icon: 'error',
                    title: 'No se pudo cambiar la sucursal',
                    text: 'Recarga la página e intenta nuevamente.'
                })
            })
    }
}