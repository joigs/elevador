import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["button"]

    submitAndRedirect(event) {
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
                        text: 'No se pudieron guardar los cambios.',
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
    }
}
