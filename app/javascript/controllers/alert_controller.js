import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    static values = { message: String, type: String, confirmDeletion: Boolean }

    connect() {
        if (this.confirmDeletionValue) {
            this.showConfirmation()
        } else if (this.messageValue) {
            this.showAlert()
        }
    }

    showAlert() {
        Swal.fire({
            icon: this.typeValue || 'info',
            title: this.messageValue,
        })
    }

    showConfirmation() {
        Swal.fire({
            icon: 'warning',
            title: this.messageValue,
            showCancelButton: true,
            confirmButtonText: 'Sí, eliminar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.isConfirmed) {
                this.forceDeleteRevisions()
            }
        })
    }

    forceDeleteRevisions() {
        // Agregar el parámetro 'force_delete_revisions' y reenviar el formulario
        const form = this.element.closest('form')
        const formData = new FormData(form)
        formData.append('force_delete_revisions', '1')

        fetch(form.action, {
            method: form.method,
            headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content') },
            body: formData
        })
            .then(response => response.json())
            .then(data => {
                Swal.fire({
                    icon: data.type || 'success',
                    title: data.message,
                }).then(() => {
                    if (data.redirect_url) {
                        window.location.href = data.redirect_url
                    }
                })
            })
            .catch(error => {
                Swal.fire({
                    icon: 'error',
                    title: 'Ocurrió un error al eliminar las revisiones.',
                })
            })
    }
}
