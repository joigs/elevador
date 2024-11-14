import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    confirm(event) {
        event.preventDefault()
        const message = "¿Estás seguro de que quieres terminar la inspección?"
        const form = event.target.closest('form')
        Swal.fire({
            title: 'Confirmación',
            text: message,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, terminar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'  // Aplica margen a la derecha del botón de confirmación
            }
        }).then((result) => {
            if (result.isConfirmed) {
                form.requestSubmit()
            }
        })
    }
}
