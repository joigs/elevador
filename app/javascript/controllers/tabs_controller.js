import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["originalSection", "reducedSection", "originalTabBtn", "reducedTabBtn"]

    connect() {
        this.showOriginal()
    }

    showOriginal() {
        this.originalSectionTarget.classList.remove("hidden")
        this.reducedSectionTarget.classList.add("hidden")

        this.originalTabBtnTarget.classList.add("bg-gray-400")
        this.reducedTabBtnTarget.classList.remove("bg-gray-400")
    }

    showReduced() {
        this.reducedSectionTarget.classList.remove("hidden")
        this.originalSectionTarget.classList.add("hidden")

        this.reducedTabBtnTarget.classList.add("bg-gray-400")
        this.originalTabBtnTarget.classList.remove("bg-gray-400")
    }
}
