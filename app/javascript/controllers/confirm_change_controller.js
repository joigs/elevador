import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
    static targets = ["form"]

    // Método que se ejecuta al hacer clic en "Cambiar Grupo"
    confirmChange(event) {
        event.preventDefault()

        Swal.fire({
            title: "¿Estás seguro?",
            text: "Cambiar de grupo eliminara todos los datos de las inspecciones (defectos, comentarios, imagenes, detalle de inspección)",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Sí, cambiar",
            cancelButtonText: "No, cancelar",
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.formTarget.submit()
            } else {
                window.location.href = this.data.get("cancelUrl")
            }
        })
    }
}
