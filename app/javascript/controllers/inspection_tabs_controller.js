import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["detail", "report", "buttonDetail", "buttonReport"]

    connect() {
        // Al iniciar, mostramos la pestaña de detalle por defecto
        this.showDetail()
    }

    showDetail() {
        // Mostrar la pestaña de detalle y ocultar la de reporte
        this.detailTarget.classList.remove("hidden")
        this.reportTarget.classList.add("hidden")

        // Marcar el botón activo
        this.buttonDetailTarget.classList.remove("bg-blue-600")
        this.buttonDetailTarget.classList.add("bg-blue-800")

        // Restablecer el estilo del otro botón
        this.buttonReportTarget.classList.remove("bg-blue-800")
        this.buttonReportTarget.classList.add("bg-blue-600")
    }

    showReport() {
        // Mostrar la pestaña de reporte y ocultar la de detalle
        this.reportTarget.classList.remove("hidden")
        this.detailTarget.classList.add("hidden")

        // Marcar el botón activo
        this.buttonReportTarget.classList.remove("bg-blue-600")
        this.buttonReportTarget.classList.add("bg-blue-800")

        // Restablecer el estilo del otro botón
        this.buttonDetailTarget.classList.remove("bg-blue-800")
        this.buttonDetailTarget.classList.add("bg-blue-600")
    }
}
