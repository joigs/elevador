import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["newObservacion", "observacionesList", "observacion", "observacionTexto", "observacionEdit", "observacionUpdateButton"];
    static values = { url: String };

    async createObservacion() {
        const texto = this.newObservacionTarget.value.trim();
        if (!texto) return alert("La observación no puede estar vacía.");

        const response = await fetch(this.urlValue, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            },
            body: JSON.stringify({ observacion: { texto } }),
        });

        if (response.ok) {
            const nuevaObservacion = await response.text();
            this.observacionesListTarget.insertAdjacentHTML("afterbegin", nuevaObservacion);
            this.newObservacionTarget.value = ""; // Limpia el campo de texto
        } else {
            alert("No se pudo crear la observación.");
        }
    }

    editObservacion(event) {
        const observacionElement = event.target.closest("[data-observaciones-target='observacion']");
        const textoElement = observacionElement.querySelector("[data-observaciones-target='observacionTexto']");
        const editElement = observacionElement.querySelector("[data-observaciones-target='observacionEdit']");
        const updateButton = observacionElement.querySelector("[data-observaciones-target='observacionUpdateButton']");

        textoElement.classList.add("hidden");
        editElement.classList.remove("hidden");
        updateButton.classList.remove("hidden");
    }

    async updateObservacion(event) {
        const observacionElement = event.target.closest("[data-observaciones-target='observacion']");
        const editElement = observacionElement.querySelector("[data-observaciones-target='observacionEdit']");
        const textoElement = observacionElement.querySelector("[data-observaciones-target='observacionTexto']");
        const updateButton = observacionElement.querySelector("[data-observaciones-target='observacionUpdateButton']");
        const id = observacionElement.dataset.id;

        const texto = editElement.value.trim();
        if (!texto) return alert("La observación no puede estar vacía.");

        const url = `${this.urlValue}/${id}`;

        const response = await fetch(url, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            },
            body: JSON.stringify({ observacion: { texto } }),
        });

        if (response.ok) {
            textoElement.textContent = texto;
            textoElement.classList.remove("hidden");
            editElement.classList.add("hidden");
            updateButton.classList.add("hidden");
        } else {
            alert("No se pudo actualizar la observación.");
        }
    }
    deleteObservacion(event) {
        const observacionElement = event.target.closest("[data-observaciones-target='observacion']");
        const id = observacionElement.dataset.id;

        // Confirmación opcional
        if (!confirm("¿Seguro que deseas eliminar esta observación?")) return;

        const url = `${this.urlValue}/${id}`;

        fetch(url, {
            method: "DELETE",
            headers: {
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
            }
        })
            .then(response => {
                if (response.ok) {
                    observacionElement.remove();
                } else {
                    alert("No se pudo eliminar la observación.");
                }
            })
            .catch(() => alert("Error al intentar eliminar la observación."));
    }



}
