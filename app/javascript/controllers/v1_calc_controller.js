// app/javascript/controllers/v1_calc_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bruto", "neto"]

    connect() {
        this.update()
    }

    update() {
        const valorBruto = parseFloat(this.brutoTarget.value)
        if (!isNaN(valorBruto)) {
            const neto = +(valorBruto / 1.19).toFixed(2)
            this.netoTarget.value = neto
        } else {
            this.netoTarget.value = ""
        }
    }
}
