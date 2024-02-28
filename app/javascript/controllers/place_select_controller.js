import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["principal", "placeList"]

    connect() {
        document.addEventListener('principalChanged', event => this.updatePlaces(event));
    }

    updatePlaces(event) {
        const principalId = event.detail.principalId; // Get the principal ID from the event
        const placeList = this.placeListTarget;

        fetch(`/principals/${principalId}/places`)
            .then(response => response.json())
            .then(data => {
                // Clear existing options
                placeList.innerHTML = '';

                // Add new options based on fetched data
                data.forEach((place) => {
                    const option = document.createElement('option');
                    option.value = place;
                    placeList.appendChild(option);
                });
            })
            .catch(error => console.error('Error fetching places:', error));
    }
}
