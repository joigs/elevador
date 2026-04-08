import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["checkbox"]

    connect() {
        const isRellenoVisible = sessionStorage.getItem("showRelleno") === "true"
        this.checkboxTarget.checked = isRellenoVisible
    }

    toggle() {
        const isChecked = this.checkboxTarget.checked
        sessionStorage.setItem("showRelleno", isChecked)

        const frame = document.getElementById("users")

        const currentUrl = new URL(frame.src || window.location.href)

        if (isChecked) {
            currentUrl.searchParams.set("show_relleno", "true")
        } else {
            currentUrl.searchParams.delete("show_relleno")
        }

        frame.src = currentUrl.href
    }
}