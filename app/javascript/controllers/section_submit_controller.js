import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button"]

    submitAndNavigate(event) {
        event.preventDefault();
        const url = event.currentTarget.dataset.url;
        const form = this.element.closest('form');

        // Submit form via AJAX
        fetch(form.action, {
            method: 'POST',
            body: new FormData(form),
            headers: { 'X-CSRF-Token': document.querySelector("[name='csrf-token']").content },
            redirect: 'follow'
        })
            .then(response => {
                if (response.ok) {
                    window.location.href = url;
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Error al guardar los cambios.',
                        showCancelButton: false,
                        showConfirmButton: false
                    });
                }
            });
    }
}
