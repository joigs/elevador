//app/javascript/controllers/section_submit_controller.js
import { Controller } from "@hotwired/stimulus"

//controlador para los botones de las secciones en la revision
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
                    alert('Error al guardar los cambios.');
                }
            });
    }
}
