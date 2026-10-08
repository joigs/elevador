import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    static values = { nombre: String }

    confirm(event) {
        event.preventDefault()
        const form = this.element

        Swal.fire({
            title: '¿Estás seguro?',
            text: `¿Estás seguro de que quieres eliminar "${this.nombreValue}"? Esta acción no se puede deshacer.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, eliminar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                form.submit()
            }
        })
    }
}