import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    static values = {
        info: Array
    }

    openInfo() {
        const listItems = this.infoValue.map(item => `<li>${item}</li>`).join('')
        const listHtml = `<ul class="list-disc ml-5">${listItems}</ul>`

        Swal.fire({
            title: 'Información',
            html: `
        <div style="max-height: 200px; overflow-y: auto;">
          ${listHtml}
        </div>
      `,
            showCloseButton: true,
            confirmButtonText: 'Cerrar',
            focusConfirm: false
        })
    }
}
