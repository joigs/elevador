import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        setUrl: String,
        updateUrl: String,
        initial: String,
        csrf: String,
        labelSelector: String
    }
    static targets = ["editor"]

    connect() {
        this.beforeCacheHandler = () => this.teardown()
        this.pageShowHandler    = (e) => { if (e.persisted) this.reinitIfNeeded() }

        document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
        window.addEventListener("pageshow", this.pageShowHandler)

        if (this.initialValue) this.renderEditor(this.initialValue)
    }

    disconnect() {
        document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
        window.removeEventListener("pageshow", this.pageShowHandler)
        this.teardown()
    }

    markToday() {
        fetch(this.setUrlValue, {
            method: "PATCH",
            headers: { "X-CSRF-Token": this.csrfValue }
        })
            .then(r => r.json())
            .then(data => {
                if (!data.success) { alert("No se pudo establecer la fecha."); return }
                this.renderEditor(data.fecha_venta)
                this.updateLabel(data.fecha_venta)
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
                if (!data.success) { alert(data.message || "No se pudo actualizar la fecha."); return }
                this.updateLabel(data.fecha_venta)
            })
            .catch(() => alert("Error de red al actualizar la fecha."))
    }

    renderEditor(valorInicial) {
        this.element.innerHTML = `
      <div data-fecha-venta-target="editor" class="flex items-center gap-3">
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
    `
        this.initPicker(valorInicial)
    }

    initPicker(valorInicial) {
        const el = this.inputEl()
        if (!el) return

        this.teardown()

        if (window.flatpickr) {
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
        } else {
            el.value = valorInicial || ""
        }
    }

    teardown() {
        if (this.fp) {
            try { this.fp.destroy() } catch (_) {}
            this.fp = null
        }
    }

    reinitIfNeeded() {
        if (this.inputEl() && !this.fp) {
            const current = this.inputEl().value || this.initialValue || ""
            this.initPicker(current)
        }
    }

    inputEl() { return this.element.querySelector('[data-fecha-venta-target="input"]') }

    updateLabel(dmy) {
        const el = document.querySelector(this.labelSelectorValue)
        if (el) el.textContent = dmy
    }
}
