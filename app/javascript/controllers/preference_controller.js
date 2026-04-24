import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    toggle(event) {
        const isChecked = event.target.checked
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content

        fetch(this.urlValue, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({ valor: isChecked })
        }).then(response => {
            if (!response.ok) {
                event.target.checked = !isChecked
            }
        })
    }
}