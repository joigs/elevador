
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
                identificadorList.innerHTML = '';

                data.forEach((item) => {
                    const option = document.createElement('option');
                    option.value = item.identificador;
                    identificadorList.appendChild(option);
                });
                this.dispatchPrincipalChangedEvent(principalId);
            })
            .catch(error => console.error('Error al obtener los activos:', error));

    }
    dispatchPrincipalChangedEvent(principalId) {
        const event = new CustomEvent('principalChanged', { detail: { principalId: principalId } });
        document.dispatchEvent(event);
    }
}
