// app/javascript/controllers/form_completion_alert_controller.js


//Sirve para mostrar una alerta de SweetAlert2 si el admin intenta modificar el formulario de detail o report para una inspeccion abierta.

import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
    static values = {
        destinationUrl: String,
        isInspectionOpen: Boolean
    }

    handleClick(event) {
        if (!this.isInspectionOpenValue) {
            return
        }

        event.preventDefault()

        Swal.fire({
            title: 'Inspección en proceso',
            text: 'Puede que el inspector aún esté ingresando información. ¿Desea continuar de todas formas?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            },
            didOpen: () => {
                const confirmBtn = Swal.getConfirmButton()

                confirmBtn.setAttribute(
                    'title',
                    'Si el inspector está dentro del formulario al mismo tiempo, podría haber pérdida de información.'
                )
            }
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = this.destinationUrlValue
            }

        })
    }
}
