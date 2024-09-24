import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
    static targets = ["input", "button"]

    connect() {
        this.maxPage = parseInt(this.data.get("maxPages"));  // Asegúrate de que maxPages sea un número
        this.url = this.data.get("url");

        // Añadir listener para la tecla Enter
        this.inputTarget.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                this.goToPage();  // Llamar a la función de búsqueda cuando se presiona Enter
            }
        });
    }

    goToPage() {
        const page = parseInt(this.inputTarget.value);  // Asegúrate de que sea un número

        if (page >= 1 && page <= this.maxPage) {
            const url = `${this.url}?page=${page}`;
            Turbo.visit(url, { frame: 'items' });
        } else {
            alert(`Ingrese un número de página válido entre 1 y ${this.maxPage}`);
        }
    }
}
