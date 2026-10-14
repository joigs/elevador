import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { inspecciones: Number }

    confirm(event) {
        event.preventDefault()
        const form = this.element

        if (this.inspeccionesValue > 0) {
            const n = this.inspeccionesValue
            window.Swal.fire({
                icon: 'error',
                title: 'No se puede eliminar',
                text: `Esta sucursal tiene ${n} ${n === 1 ? 'inspección asociada' : 'inspecciones asociadas'}. Cambia esas inspecciones a otra sucursal antes de eliminarla.`,
                confirmButtonText: 'Entendido'
            })
            return
        }

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