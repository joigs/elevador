import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["detail", "report", "buttonDetail", "buttonReport"]

    connect() {
        this.showDetail()
    }

    showDetail() {
        this.detailTarget.classList.remove("hidden")
        this.reportTarget.classList.add("hidden")

        this.buttonDetailTarget.classList.remove("bg-blue-600")
        this.buttonDetailTarget.classList.add("bg-blue-800")

        this.buttonReportTarget.classList.remove("bg-blue-800")
        this.buttonReportTarget.classList.add("bg-blue-600")
    }

    showReport() {
        this.reportTarget.classList.remove("hidden")
        this.detailTarget.classList.add("hidden")

        this.buttonReportTarget.classList.remove("bg-blue-600")
        this.buttonReportTarget.classList.add("bg-blue-800")

        this.buttonDetailTarget.classList.remove("bg-blue-800")
        this.buttonDetailTarget.classList.add("bg-blue-600")
    }
}
