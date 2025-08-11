import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input"]
  static values  = { url: String }

  connect () {
    this.csrfToken = document.querySelector("meta[name='csrf-token']").content
  }

  showForm () {
    this.inputTarget.value = this.displayTarget.innerText.trim() === "—" ? "" : this.displayTarget.innerText.trim()
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }

  submit (event) {
    event.preventDefault()

    const formData = new FormData()
    formData.append("authenticity_token", this.csrfToken)
    formData.append("facturacion[empresa_provisional]", this.inputTarget.value)

    fetch(this.urlValue, {
      method: "PATCH",
      body:   formData
    })
      .then(r => r.json())
      .then(data => {
        if (data.success) {
          this.displayTarget.textContent = data.empresa_provisional || "—"
          this.displayTarget.classList.remove("hidden")
          this.formTarget.classList.add("hidden")
        } else {
          alert("No se pudo actualizar la empresa provisional.")
        }
      })
      .catch(() => alert("Error inesperado al guardar la empresa provisional."))
  }

  cancel () {
    this.formTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }
}
