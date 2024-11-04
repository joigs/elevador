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
            icon: this.typeValue || 'warning',
            title: this.messageValue,
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.isConfirmed) {
                this.forceDeleteRevisions()
            }
        })
    }

    forceDeleteRevisions() {
        const form = this.element
        const formData = new FormData(form)
        formData.append('force_delete_revisions', '1')

        fetch(form.action, {
            method: form.method,
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
            },
            body: formData,
            credentials: 'same-origin',
        })
            .then(response => {
                if (response.redirected) {
                    window.location.href = response.url
                } else {
                    response.text().then((html) => {
                        const parser = new DOMParser()
                        const doc = parser.parseFromString(html, 'text/html')
                        const newForm = doc.querySelector('form[data-controller="alert"]')
                        if (newForm) {
                            form.replaceWith(newForm)
                        } else {
                            window.location.reload()
                        }
                    })
                }
            })
            .catch(error => {
                Swal.fire({
                    icon: 'error',
                    title: 'Ocurrió un error al eliminar las revisiones.',
                })
            })
    }
}
