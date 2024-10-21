import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
    static targets = ["file", "filename"];

    connect() {
        this.fileTargets.forEach((input, index) => {
            input.addEventListener('change', (event) => this.fileChanged(event, index));
        });
    }

    fileChanged(event, index) {
        const file = event.target.files[0];
        if (file && file.type.startsWith('image/')) {
            const canvas = document.getElementById('canvas_' + index);
            const ctx = canvas.getContext('2d');
            const img = new Image();

            img.onload = function() {
                // Reducing the image dimensions to half
                let width = img.width / 2;
                let height = img.height / 2;

                canvas.width = width;
                canvas.height = height;
                ctx.drawImage(img, 0, 0, width, height);

                canvas.toBlob(function(blob) {
                    const newFile = new File([blob], file.name, { type: file.type });
                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(newFile);
                    event.target.files = dataTransfer.files;

                    // Update the label to show the resized file name
                    const filenameSpan = event.target.nextElementSibling.querySelector('span');
                    if (filenameSpan) {
                        filenameSpan.textContent = newFile.name;
                    }
                }, file.type);
            };

            const reader = new FileReader();
            reader.onload = function(e) {
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }
}
