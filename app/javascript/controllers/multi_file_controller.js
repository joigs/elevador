// app/javascript/controllers/multi_file_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "list"]

    connect() {
        this.entries = []
    }

    disconnect() {
        this.entries.forEach((e) => URL.revokeObjectURL(e.url))
    }

    async added(event) {
        const picked = Array.from(event.target.files || [])
        if (!picked.length) return

        for (const original of picked) {
            // clave para no duplicar si eligen el mismo archivo dos veces
            const key = `${original.name}|${original.size}|${original.lastModified}`
            if (this.entries.some((e) => e.key === key)) continue

            const file = await this.process(original)
            this.entries.push({ file, key, url: URL.createObjectURL(file) })
        }

        this.sync()
    }

    remove(event) {
        const key = event.currentTarget.dataset.key
        const i = this.entries.findIndex((e) => e.key === key)
        if (i === -1) return

        URL.revokeObjectURL(this.entries[i].url)
        this.entries.splice(i, 1)
        this.sync()
    }

    async process(file) {
        if (window.resizeReduced === false) return file
        if (!file.type.startsWith("image/")) return file

        const resizer = this.application.getControllerForElementAndIdentifier(this.element, "image-resize")
        if (!resizer) return file

        try {
            return await resizer.resizeFile(file)
        } catch (error) {
            console.error("Error al redimensionar la imagen:", error)
            return file
        }
    }

    sync() {
        const dt = new DataTransfer()
        this.entries.forEach((e) => dt.items.add(e.file))
        this.inputTarget.files = dt.files
        this.render()
    }

    render() {
        this.listTarget.innerHTML = ""

        this.entries.forEach((e) => {
            const row = document.createElement("div")
            row.className = "flex items-center gap-2 mt-2"

            const img = document.createElement("img")
            img.src = e.url
            img.alt = e.file.name
            img.style.maxWidth = "120px"
            img.style.borderRadius = "4px"

            const name = document.createElement("span")
            name.className = "text-xs text-gray-400 break-all flex-1"
            name.textContent = e.file.name

            const btn = document.createElement("button")
            btn.type = "button"
            btn.textContent = "✕"
            btn.title = "Quitar esta imagen"
            btn.className = "bg-red-600 hover:bg-red-700 text-white text-xs font-bold px-2 py-1 rounded"
            btn.dataset.key = e.key
            btn.dataset.action = "click->multi-file#remove"

            row.append(img, name, btn)
            this.listTarget.appendChild(row)
        })
    }
}