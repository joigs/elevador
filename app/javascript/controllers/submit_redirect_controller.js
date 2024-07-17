// app/javascript/controllers/submit_redirect_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    submitAndRedirect(event) {
        event.preventDefault();
        const url = this.data.get("redirectUrl");
        const form = this.element.closest('form');

        // Submit form via AJAX
        fetch(form.action, {
            method: form.method,
            body: new FormData(form),
            headers: { 'X-CSRF-Token': document.querySelector("[name='csrf-token']").content },
            redirect: 'follow'
        })
            .then(response => {
                if (response.ok) {
                    window.location.href = url;
                } else {
                    alert('Error al guardar los cambios.');
                }
            });
    }
}
