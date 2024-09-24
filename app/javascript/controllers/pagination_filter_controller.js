// app/javascript/controllers/pagination_filter_controller.js
import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";
import Swal from 'sweetalert2';

export default class extends Controller {
    static targets = ["input"]

    connect() {
        this.maxPage = parseInt(this.data.get("maxPages"));
        this.url = this.data.get("url");
        this.filter = this.data.get("filter");

        // Añadir listener para la tecla Enter
        this.inputTarget.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                this.goToPage();
            }
        });
    }

    goToPage() {
        const page = parseInt(this.inputTarget.value);

        if (page >= 1 && page <= this.maxPage) {
            let url = `${this.url}?page=${page}`;
            if (this.filter) {
                url += `&filter=${this.filter}`;
            }
            Turbo.visit(url, { frame: 'inspections' });
        } else {
            Swal.fire({
                icon: "warning",
                title: "Página inválida",
                text: `Ingrese un número de página válido entre 1 y ${this.maxPage}`,
                confirmButtonText: "Entendido"
            });
        }
    }
}