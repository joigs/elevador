import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["table"]

    connect() {
        this.rows = Array.from(this.tableTarget.querySelectorAll("tbody tr"));
        this.rowsPerPage = this.data.get("rowsPerPage") || 10;
        this.pageCount = Math.ceil(this.rows.length / this.rowsPerPage);
        this.currentPage = 1;
        this.createPagination();
        this.showPage(this.currentPage);
    }

    createPagination() {
        const pagination = document.createElement("div");
        pagination.classList.add("pagination", "flex", "justify-center", "mt-4");

        // Botón "Anterior"
        const prevButton = document.createElement("button");
        prevButton.innerText = "Anterior";
        prevButton.classList.add("pagination-button", "mx-2", "px-4", "py-2", "bg-gray-800", "text-white", "rounded");
        prevButton.disabled = this.currentPage === 1;
        prevButton.addEventListener("click", () => this.showPage(this.currentPage - 1));
        pagination.appendChild(prevButton);

        // Páginas con límite de botones
        const maxVisibleButtons = 5;
        const halfMaxVisible = Math.floor(maxVisibleButtons / 2);
        let startPage = Math.max(1, this.currentPage - halfMaxVisible);
        let endPage = Math.min(this.pageCount, this.currentPage + halfMaxVisible);

        if (this.currentPage - halfMaxVisible <= 0) {
            endPage = Math.min(this.pageCount, maxVisibleButtons);
        }

        if (this.currentPage + halfMaxVisible > this.pageCount) {
            startPage = Math.max(1, this.pageCount - maxVisibleButtons + 1);
        }

        for (let i = startPage; i <= endPage; i++) {
            const button = document.createElement("button");
            button.innerText = i;
            button.classList.add("pagination-button", "mx-2", "px-4", "py-2", `${i === this.currentPage ? "bg-blue-600" : "bg-gray-800"}`, "text-white", "rounded");
            button.addEventListener("click", () => this.showPage(i));
            pagination.appendChild(button);
        }

        // Botón "Siguiente"
        const nextButton = document.createElement("button");
        nextButton.innerText = "Siguiente";
        nextButton.classList.add("pagination-button", "mx-2", "px-4", "py-2", "bg-gray-800", "text-white", "rounded");
        nextButton.disabled = this.currentPage === this.pageCount;
        nextButton.addEventListener("click", () => this.showPage(this.currentPage + 1));
        pagination.appendChild(nextButton);

        // Reemplazar la paginación actual si ya existe
        const existingPagination = this.element.querySelector(".pagination");
        if (existingPagination) {
            existingPagination.remove();
        }

        // Añadir paginación al DOM
        this.element.appendChild(pagination);
    }

    showPage(page) {
        this.currentPage = page;
        const start = (page - 1) * this.rowsPerPage;
        const end = start + this.rowsPerPage;

        this.rows.forEach((row, index) => {
            row.style.display = index >= start && index < end ? "" : "none";
        });

        // Actualizar la paginación después de cambiar la página
        this.createPagination();
    }
}
