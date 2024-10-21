// app/javascript/controllers/show_comment_on_upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["file"]

    fileChanged() {
        const file = this.fileTarget.files[0];
        if (file) {
            // Mostrar el campo de comentario
            const commentContainer = document.getElementById('imagen_general_comment_container');
            if (commentContainer) {
                commentContainer.classList.remove('hidden');
            }
        }
    }
}
