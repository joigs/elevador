import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "select", "hidden"]

    connect () {
        // si el input empieza con algo, sincroniza hidden
        this.hiddenTarget.value = this.inputTarget.value.trim()

        // actualiza hidden cuando el usuario escribe libremente
        this.inputTarget.addEventListener("input", () => {
            if (!this.inputTarget.disabled) {
                this.hiddenTarget.value = this.inputTarget.value.trim()
            }
        })
    }

    pick (event) {
        const val = event.target.value

        if (val === "") {
            // Sin selección → desbloquear el input
            this.inputTarget.disabled = false
            this.inputTarget.classList.remove("opacity-50", "cursor-not-allowed")
            this.hiddenTarget.value = this.inputTarget.value.trim()
            this.inputTarget.focus()
        } else {
            // Opción elegida → bloquear input y copiar valor
            this.inputTarget.value    = val
            this.inputTarget.disabled = true
            this.inputTarget.classList.add("opacity-50", "cursor-not-allowed")
            this.hiddenTarget.value   = val
        }
    }
}
