import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirmarAgregar(event) {
        const select = event.target
        const form = this.element
        if (!select.value) return

        const nombre = select.options[select.selectedIndex].text

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: `¿Quieres agregar este usuario a ${nombre}?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#2563eb',
            cancelButtonColor: '#6b7280',
            confirmButtonText: 'Sí, agregar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                form.requestSubmit()
            } else {
                select.value = ""
            }
        })
    }

    confirmarQuitar(event) {
        event.preventDefault()
        const form = this.element
        const nombre = event.currentTarget.dataset.nombre

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: `¿Quieres quitar este usuario de ${nombre}?.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, quitar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                form.requestSubmit()
            }
        })
    }
}