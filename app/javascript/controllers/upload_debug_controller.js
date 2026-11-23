import { Controller } from "@hotwired/stimulus"

// Diagnóstico temporal del formulario de informe
export default class extends Controller {
    connect() {
        this.onError = (e) => this.log("js-error", { msg: e.message, src: e.filename, line: e.lineno })
        window.addEventListener("error", this.onError)
        this.log("connect", {
            ua: navigator.userAgent,
            sw: navigator.serviceWorker?.controller?.scriptURL || null
        })
    }

    disconnect() {
        window.removeEventListener("error", this.onError)
    }

    click()  { this.log("click-subir", this.fileInfo()) }
    submit() { this.log("submit", this.fileInfo()) }
    start()  { this.log("turbo-start") }

    end(event) {
        const { success, fetchResponse, error } = event.detail
        this.log("turbo-end", {
            success,
            status: fetchResponse?.statusCode ?? null,
            error: error ? String(error) : null
        })
    }

    error(event) {
        this.log("fetch-error", { error: String(event.detail?.error) })
    }

    fileInfo() {
        const f = this.element.querySelector('input[type="file"]')?.files?.[0]
        return f ? { name: f.name, size: f.size, type: f.type } : { file: null }
    }

    log(evt, data = {}) {
        const body = JSON.stringify({ evt, page: location.pathname, ...data })
        console.log("[upload-debug]", body)
        navigator.sendBeacon("/client_logs", new Blob([body], { type: "application/json" }))
    }
}