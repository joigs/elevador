// app/javascript/controllers/principal_select_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["principal", "item"]

    updateItems(event) {
        const principalId = this.principalTarget.value;
        const itemSelect = this.itemTarget;
        fetch(`/principals/${principalId}/items`)
            .then(response => response.json())
            .then(data => {
                itemSelect.innerHTML = '<option value="">Seleccione un identificador</option>';
                data.forEach((item) => {
                    const option = new Option(item.identificador, item.identificador);
                    itemSelect.add(option);
                });
                // Trigger SlimSelect update
                this.dispatch('slim-select:update', { target: itemSelect, detail: { options: data.map(item => ({ text: item.identificador, value: item.identificador })) } });
            })
            .catch(error => console.error('Error fetching items:', error));
    }
}
