import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "row", "empty"]

    filter() {
        const query = this.inputTarget.value.trim().toLowerCase()
        let visibles = 0

        this.rowTargets.forEach((row) => {
            const texto = (row.dataset.searchable || row.textContent).toLowerCase()
            const coincide = query === "" || texto.includes(query)
            row.classList.toggle("hidden", !coincide)
            if (coincide) visibles++
        })

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.toggle("hidden", visibles > 0)
        }
    }

    clear() {
        this.inputTarget.value = ""
        this.filter()
    }
}