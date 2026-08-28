import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
    static targets = ["form"]

    static values = {
        inspeccion: String,
        activo: String,
        cerrada: Boolean
    }

    confirm(event) {
        event.preventDefault()

        const texto = `La inspección quedará registrada con el identificador ${this.activoValue} en lugar de ${this.inspeccionValue}.`

        Swal.fire({
            title: '¿Actualizar el identificador de la inspección?',
            text: texto,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, actualizar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-20'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.formTarget.requestSubmit()
            }
        })
    }
}