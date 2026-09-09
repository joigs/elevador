import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirm(event) {
        if (this.confirmed) return

        event.preventDefault()

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: "Al desactivar la empresa, sus usuarios no podrán iniciar sesión.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, desactivar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.confirmed = true
                this.element.click()
            }
        })
    }
}