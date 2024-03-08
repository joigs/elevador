import { Controller } from "@hotwired/stimulus"

//Controlador para agrandar imagenes al hacerles click
export default class extends Controller {
  static targets = ["source"];

  show(event) {
    event.preventDefault();
    const imageUrl = event.currentTarget.dataset.imageUrl;

    const overlay = document.createElement('div');
    overlay.style = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background-color: rgba(0, 0, 0, 0.8);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 9999;
    `;
    overlay.id = 'image-overlay';

    const img = document.createElement('img');
    img.src = imageUrl;
    img.style = 'max-width: 90%; max-height: 90%;';
    overlay.appendChild(img);

    document.body.appendChild(overlay);

    overlay.addEventListener('click', () => document.body.removeChild(overlay));
  }
}
