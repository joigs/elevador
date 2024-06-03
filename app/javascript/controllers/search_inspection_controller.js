import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["clearButton", "searchField", "numberField", "form"]

    connect() {
        this.toggleClearButton()
    }

    toggleClearButton() {
        if (this.searchFieldTarget.value.length > 0 || this.numberFieldTarget.value.length > 0) {
            this.clearButtonTarget.style.display = 'block';
        } else {
            this.clearButtonTarget.style.display = 'none';
        }
    }

    submitForm() {
        this.formTarget.requestSubmit();
    }

    resetSearch() {
        this.searchFieldTarget.value = '';
        this.numberFieldTarget.value = '';
        this.toggleClearButton();
        this.formTarget.requestSubmit();
    }
}
