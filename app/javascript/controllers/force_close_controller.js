// app/javascript/controllers/force_close_controller.js

import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

// Controlador para forzar cierre de inspección como admin
export default class extends Controller {
    static values = {
        hasIncompleteRevisionColors: Boolean
    }

    confirmClose(event) {
        event.preventDefault()
        Swal.fire({
            title: '¿Estás seguro?',
            text: 'Va a cerrar la inspección y se recomienda que el inspector sea quien lo haga.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, cerrar inspección',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-20'  // Aplica margen a la derecha del botón de confirmación
            }
        }).then((result) => {
            if (result.isConfirmed) {
                if (this.hasIncompleteRevisionColorsValue) {
                    // Mostrar segunda advertencia
                    Swal.fire({
                        title: 'Advertencia',
                        text: 'El inspector aún no marca que terminó la inspección, por lo que podría haber información errónea.',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonText: 'Cerrar de todas formas',
                        cancelButtonText: 'Cancelar',
                        customClass: {
                            confirmButton: 'mr-10'  // Aplica margen a la derecha del botón de confirmación
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            this.submitForm()
                        }
                    })
                } else {
                    this.submitForm()
                }
            }
        })
    }

    submitForm() {
        const form = document.getElementById('force-close-form')
        if (form) {
            form.submit()
        } else {
            console.error("Formulario oculto 'force-close-form' no encontrado.")
        }
    }
}
