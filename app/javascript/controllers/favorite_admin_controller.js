import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    update(event) {
        const adminId = event.target.value
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content

        if (!adminId) return

        fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({ admin_id: adminId })
        })
    }
}