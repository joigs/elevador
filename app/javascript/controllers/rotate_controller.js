// app/javascript/controllers/rotate_controller.js
import { Controller } from "@hotwired/stimulus"

// Stimulus controller for rotating images
export default class extends Controller {
    rotateLeft(event) {
        this.rotate(event, -90);
    }

    rotateRight(event) {
        this.rotate(event, 90);
    }

    rotate(event, degrees) {
        event.preventDefault();

        const photoId = this.element.dataset.photoId;
        console.log("Photo ID:", photoId); // Debugging line
        const url = `/revision_photos/${photoId}/rotate`;
        console.log("URL:", url); // Debugging line
        const params = {
            degrees: degrees
        };

        fetch(url, {
            method: 'PATCH',
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
            body: JSON.stringify(params)
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Reload the image to show the rotated version
                    const img = this.element.querySelector('img');
                    const timestamp = new Date().getTime();
                    img.src = img.src.split('?')[0] + '?t=' + timestamp;
                    window.location.reload()

                } else {
                    alert('Error rotando imagen');
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
}
