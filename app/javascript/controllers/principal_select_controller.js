// app/javascript/controllers/principal_select_controller.js

import { Controller } from "@hotwired/stimulus"

//controlador para obtener los activos de una empresa
export default class extends Controller {



    static targets = ["principal", "identificadorList"]


    connect() {
    }

    updateItems(event) {
        const principalId = this.principalTarget.value;
        const identificadorList = this.identificadorListTarget;

        fetch(`/principals/${principalId}/items`)
            .then(response => response.json())
            .then(data => {
                // Clear existing options
                identificadorList.innerHTML = '';

                // Add new options based on fetched data
                data.forEach((item) => {
                    const option = document.createElement('option');
                    option.value = item.identificador;
                    identificadorList.appendChild(option);
                });
                // Note: No need to trigger a SlimSelect update here as we're not using SlimSelect for a datalist
            })
            .catch(error => console.error('Error fetching items:', error));
    }
}
