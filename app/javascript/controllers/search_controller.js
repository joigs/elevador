import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["clearButton", "searchField"]

    connect() {
        this.toggleClearButton()
    }

    toggleClearButton() {
        if (this.searchFieldTarget.value.length > 0) {
            this.clearButtonTarget.style.display = 'block';
        } else {
            this.clearButtonTarget.style.display = 'none';
        }
    }

    resetSearch() {
        this.searchFieldTarget.value = '';
        this.toggleClearButton();
        this.element.submit();  // Si deseas enviar el formulario automáticamente al limpiar
    }
}
