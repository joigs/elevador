import { Controller } from "@hotwired/stimulus";
import Swal from "sweetalert2";

export default class extends Controller {
    static targets = ["form"];

    connect() {
    }

    confirmChange(event) {
        event.preventDefault(); // Evita el envío inmediato del formulario

        Swal.fire({
            title: "¿Estás seguro?",
            text: "Cualquier defecto e imagen asociado al activo será eliminado.",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Sí, cambiar grupo",
            cancelButtonText: "Cancelar",
        }).then((result) => {
            if (result.isConfirmed) {
                this.formTarget.submit(); // Envía el formulario si se confirma
            }
        });
    }
}
