import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirm(event) {
        event.preventDefault()
        const form = this.element

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: "¿Quieres eliminar esta sucursal?",
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