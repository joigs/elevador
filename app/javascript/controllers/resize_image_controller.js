import { Controller } from "@hotwired/stimulus"
export default class ResizeImageController extends Controller {
    static targets = ["file"];

    resizeImage(event) {
        const input = event.target;
        if (!input.files.length) return;
        const file = input.files[0];

        if (!file.type.startsWith('image/')) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            const img = new Image();
            img.onload = () => {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                const maxWidth = 400;
                const scaleFactor = maxWidth / img.width;

                canvas.width = maxWidth;
                canvas.height = img.height * scaleFactor;

                ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

                canvas.toBlob((blob) => {
                    const newFile = new File([blob], file.name, {
                        type: file.type,
                        lastModified: Date.now()
                    });

                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(newFile);
                    input.files = dataTransfer.files;

                    // Trigger any existing change handlers after updating the file input
                    input.dispatchEvent(new Event('change', { bubbles: true }));
                }, file.type);
            };
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
}