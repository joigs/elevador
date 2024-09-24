import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";
import Swal from 'sweetalert2';

export default class extends Controller {
    static targets = ["input", "button"]

    connect() {
        this.maxPage = parseInt(this.data.get("maxPages"));
        this.url = this.data.get("url");

        // Añadir listener para la tecla Enter
        this.inputTarget.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();  // Prevenir el comportamiento por defecto del Enter
                this.goToPage();  // Llamar a la función de búsqueda cuando se presiona Enter
            }
        });
    }

    goToPage() {
        const page = parseInt(this.inputTarget.value);

        if (page >= 1 && page <= this.maxPage) {
            const url = `${this.url}?page=${page}`;
            Turbo.visit(url, { frame: 'items' });
        } else {
            // Usar SweetAlert en lugar del alert tradicional
            Swal.fire({
                icon: "warning",
                title: "Página inválida",
                text: `Ingrese un número de página válido entre 1 y ${this.maxPage}`,
                confirmButtonText: "Entendido"
            });
        }
    }
}
