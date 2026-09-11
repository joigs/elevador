import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirm(event) {
        event.preventDefault()
        const form = this.element

        window.Swal.fire({
            title: '¿Estás seguro?',
            text: "¿Estás seguro de que quieres eliminar este usuario?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (!result.isConfirmed) return

            window.Swal.fire({
                title: 'Confirmación final',
                text: "Esta acción no se puede deshacer. La cuenta será eliminada permanentemente.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Eliminar definitivamente',
                cancelButtonText: 'Cancelar',
                customClass: {
                    confirmButton: 'mr-10'
                }
            }).then((segundo) => {
                if (segundo.isConfirmed) {
                    form.submit()
                }
            })
        })
    }
}