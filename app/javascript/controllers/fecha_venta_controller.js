import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        setUrl: String,
        updateUrl: String,
        initial: String,
        csrf: String,
        labelSelector: String
    }

    static targets = ["editor", "input", "message"]

    connect() {

        const existingValue = this.inputEl()?.value || this.initialValue || ""

        if (this.hasEditorTarget && (existingValue || this.inputEl())) {
            this.renderEditor(existingValue)
        }
    }

    disconnect() {
        this.teardown()
    }

    markToday() {
        fetch(this.setUrlValue, {
            method: "PATCH",
            headers: { "X-CSRF-Token": this.csrfValue }
        })
            .then(r => r.json())
            .then(data => {
                if (!data.success) {
                    alert("No se pudo establecer la fecha.")
                    return
                }
                this.renderEditor(data.fecha_venta)
                this.updateLabel(data.fecha_venta)
                this.showMessage(data.fecha_venta)
            })
            .catch(() => alert("Error de red al marcar la fecha."))
    }

    save() {
        const val = this.inputEl()?.value || ""
        const fd  = new FormData()
        fd.append("facturacion[fecha_venta]", val)

        fetch(this.updateUrlValue, {
            method: "PATCH",
            body: fd,
            headers: { "X-CSRF-Token": this.csrfValue }
        })
            .then(r => r.json())
            .then(data => {
                if (!data.success) {
                    alert(data.message || "No se pudo actualizar la fecha.")
                    return
                }
                this.updateLabel(data.fecha_venta)
                this.showMessage(data.fecha_venta)
            })
            .catch(() => alert("Error al actualizar la fecha."))
    }

    renderEditor(valorInicial) {
        this._initialized = true

        this.editorTarget.innerHTML = `
      <div class="flex items-center gap-3">
        <input type="text"
               data-fecha-venta-target="input"
               class="w-64 px-3 py-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
               placeholder="dd-mm-aaaa" />
        <button type="button"
                data-action="fecha-venta#save"
                class="h-10 px-4 rounded-md bg-emerald-600 hover:bg-emerald-700 text-white font-semibold">
          Guardar
        </button>
      </div>
      <p data-fecha-venta-target="message"
         class="mt-2 text-sm text-emerald-400"></p>
    `

        this.initPicker(valorInicial)
    }

    initPicker(valorInicial) {
        this.teardown()

        const el = this.inputEl()
        if (!el || !window.flatpickr) return

        this.fp = window.flatpickr(el, {
            dateFormat: "d-m-Y",
            defaultDate: valorInicial || null,
            minDate: "01-01-2020",
            maxDate: "31-12-3000",
            locale: "es",
            static: false,
            altInput: false
        })

        if (valorInicial) el.value = valorInicial
    }

    teardown() {
        if (this.fp) {
            try { this.fp.destroy() } catch (_) {}
            this.fp = null
        }
        if (this._messageTimeout) {
            clearTimeout(this._messageTimeout)
            this._messageTimeout = null
        }
    }

    inputEl() {
        if (this.hasInputTarget) return this.inputTarget
        return this.element.querySelector('[data-fecha-venta-target="input"]')
    }

    updateLabel(dmy) {
        const el = document.querySelector(this.labelSelectorValue)
        if (el) el.textContent = dmy
    }

    showMessage(dmy) {
        if (this.hasMessageTarget) {
            this.messageTarget.textContent = `Fecha de venta actualizada al ${dmy}.`
            clearTimeout(this._messageTimeout)
            this._messageTimeout = setTimeout(() => {
                if (this.hasMessageTarget) this.messageTarget.textContent = ""
            }, 4000)
        } else {
            alert(`Fecha de venta actualizada al ${dmy}.`)
        }
    }
}
