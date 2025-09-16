import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static values = { list: Array };

    connect() {
        this.overlay = document.createElement("div");
        this.overlay.className =
            "hidden fixed inset-0 z-50 bg-black bg-opacity-50 flex items-center justify-center p-4";

        this.panel = document.createElement("div");
        this.panel.className =
            "bg-white rounded-lg shadow-lg w-full max-w-xl p-4 relative max-h-[80vh] overflow-y-auto";

        const closeBtn = document.createElement("button");
        closeBtn.type = "button";
        closeBtn.setAttribute("aria-label", "Cerrar");
        closeBtn.className =
            "absolute top-2 right-2 text-gray-500 hover:text-gray-700 text-xl leading-none";
        closeBtn.innerHTML = "&times;";
        closeBtn.addEventListener("click", () => this.close());

        this.titleEl = document.createElement("h3");
        this.titleEl.className = "text-lg font-semibold mb-3";
        this.titleEl.textContent = "Defectos copiados";

        this.content = document.createElement("div");
        this.content.className = "space-y-2";

        this.panel.appendChild(closeBtn);
        this.panel.appendChild(this.titleEl);
        this.panel.appendChild(this.content);
        this.overlay.appendChild(this.panel);
        document.body.appendChild(this.overlay);

        this._onKeyDown = (e) => {
            if (e.key === "Escape") this.close();
        };

        this._onOverlayClick = (e) => {
            if (e.target === this.overlay) this.close();
        };

        this.overlay.addEventListener("click", this._onOverlayClick);
    }

    disconnect() {
        window.removeEventListener("keydown", this._onKeyDown);
        if (this.overlay) {
            this.overlay.removeEventListener("click", this._onOverlayClick);
            this.overlay.remove();
        }
    }

    open() {
        this.content.innerHTML = "";
        const list = Array.isArray(this.listValue) ? this.listValue : [];

        if (list.length === 0) {
            const empty = document.createElement("p");
            empty.className = "text-sm text-gray-600";
            empty.textContent =
                "No hay coincidencias.";
            this.content.appendChild(empty);
        } else {
            const ul = document.createElement("ul");
            ul.className = "list-disc pl-5 space-y-1";

            list.forEach((row) => {
                const li = document.createElement("li");
                li.textContent = row;
                ul.appendChild(li);
            });

            this.content.appendChild(ul);
        }

        this.overlay.classList.remove("hidden");
        window.addEventListener("keydown", this._onKeyDown);
    }

    close() {
        this.overlay.classList.add("hidden");
        window.removeEventListener("keydown", this._onKeyDown);
    }
}
