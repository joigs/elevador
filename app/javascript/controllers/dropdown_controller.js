import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        this.menuTarget.classList.add("hidden"); // Asegúrate de que el menú esté escondido inicialmente
    }

    toggle() {
        this.menuTarget.classList.toggle("hidden"); // Función para mostrar/ocultar el menú
    }
}
