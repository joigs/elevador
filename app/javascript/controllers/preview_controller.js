// app/javascript/controllers/preview_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["fileInput", "previewImage"]

    showImage() {
        const file = this.fileInputTarget.files[0]
        if (!file) return

        const reader = new FileReader()
        reader.onload = (e) => {
            this.previewImageTarget.src = e.target.result
            this.previewImageTarget.style.display = "block"
        }
        reader.readAsDataURL(file)
    }
}
