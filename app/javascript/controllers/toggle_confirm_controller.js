import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirm(event) {
        const input = event.target
        const form = this.element
        const estadoOriginal = !input.checked

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: "¿Estás seguro de que quieres aplicar este cambio?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, aplicar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                form.requestSubmit()
            } else {
                input.checked = estadoOriginal
            }
        })
    }
}