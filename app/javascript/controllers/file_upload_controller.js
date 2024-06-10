import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
    static targets = ["file", "filename"];

    connect() {
        this.updateFilename();
    }

    updateFilename() {
        const file = this.fileTarget.files[0];
        if (file) {
            this.filenameTarget.textContent = `Archivo cargado: ${file.name}`;
        } else {
            this.filenameTarget.textContent = "No hay archivo seleccionado";
        }
    }

    fileChanged() {
        this.updateFilename();
    }
}