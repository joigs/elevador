// app/javascript/controllers/emergent_list_controller.js

//controlador para mostrar los defectos de la inspecicon anterior en una ventana emergente
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    static values = {
        emergent: Array
    }

    openPopup() {
        // Construir lista en HTML
        const listItems = this.emergentValue.map(item => `<li>${item}</li>`).join('')
        const listHtml = `<ul class="list-disc ml-5">${listItems}</ul>`

        // Mostrar ventana emergente con SweetAlert
        Swal.fire({
            title: 'Defectos anteriores',
            html: `
        <div style="max-height: 300px; overflow-y: auto;">
          ${listHtml}
        </div>
      `,
            showCloseButton: true,
            confirmButtonText: 'Cerrar',
            focusConfirm: false
        })
    }
}
