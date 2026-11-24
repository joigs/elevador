import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "tarifas-info:seleccion"

export default class extends Controller {
    static targets = ["panel", "selector", "tabla"]

    connect() {
        let guardado = null
        try { guardado = localStorage.getItem(STORAGE_KEY) } catch (e) {}

        if (guardado && [...this.selectorTarget.options].some(o => o.value === guardado)) {
            this.selectorTarget.value = guardado
        }
        this.mostrarTabla()
    }

    toggle() {
        this.panelTarget.classList.toggle("hidden")
    }

    change() {
        try { localStorage.setItem(STORAGE_KEY, this.selectorTarget.value) } catch (e) {}
        this.mostrarTabla()
    }

    mostrarTabla() {
        const nombre = this.selectorTarget.value
        this.tablaTargets.forEach(t => t.classList.toggle("hidden", t.dataset.nombre !== nombre))
    }
}