import { Controller } from "@hotwired/stimulus"

// Requiere SweetAlert2 global (Swal)
export default class extends Controller {
    static targets = ["toggleBtn", "bulkBtn", "count", "form", "checkbox", "selectAll", "onlyWhenSelecting"]
    static values = { mode: { type: Boolean, default: false }, confirmText: String }

    connect() { this.updateUI() }

    toggle() {
        this.modeValue = !this.modeValue
        if (!this.modeValue) this.clearSelection()
        this.updateUI()
    }

    selectAllChanged(e) {
        const checked = e.target.checked
        this.checkboxTargets.forEach(cb => { cb.checked = checked })
        this.updateCount()
    }

    checkboxChanged() { this.updateCount(); this.syncSelectAll() }

    async submitBulk(e) {
        e.preventDefault()
        const count = this.selectedCount()
        if (count === 0) return
        const res = await Swal.fire({
            title: '¿Confirmar?',
            text: this.confirmTextValue || 'Aplicar a seleccionadas.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí',
            cancelButtonText: 'Cancelar'
        })
        if (res.isConfirmed) this.formTarget.requestSubmit()
    }

    // helpers
    updateUI() {
        // Mostrar controles solo en modo selección
        this.onlyWhenSelectingTargets.forEach(el => {
            el.classList.toggle("invisible-slot", !this.modeValue)
        })
        if (this.hasToggleBtnTarget) {
            this.toggleBtnTarget.textContent = this.modeValue ? "Salir de selección" : "Modo selección"
        }
        if (this.hasBulkBtnTarget) this.bulkBtnTarget.disabled = this.selectedCount() === 0 || !this.modeValue
        if (this.hasCountTarget) this.countTarget.textContent = this.selectedCount()
    }

    updateCount() {
        const c = this.selectedCount()
        if (this.hasCountTarget) this.countTarget.textContent = c
        if (this.hasBulkBtnTarget) this.bulkBtnTarget.disabled = c === 0
    }

    selectedCount() { return this.checkboxTargets.filter(cb => cb.checked).length }

    clearSelection() {
        this.checkboxTargets.forEach(cb => { cb.checked = false })
        if (this.hasSelectAllTarget) this.selectAllTarget.checked = false
        this.updateCount()
    }

    syncSelectAll() {
        if (!this.hasSelectAllTarget) return
        const all = this.checkboxTargets.length > 0 && this.checkboxTargets.every(cb => cb.checked)
        this.selectAllTarget.checked = all
    }
}
