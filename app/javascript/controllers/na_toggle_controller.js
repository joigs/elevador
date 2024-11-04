// app/javascript/controllers/na_toggle_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    static targets = ["naCheckbox"];

    confirmToggleAll(event) {
        const isChecked = event.target.checked;
        const headerCheckbox = event.target;

        Swal.fire({
            title: '¿Estás seguro?',
            text: isChecked ? 'Esto marcará todos los defectos como No Aplica, si hay alguno marcado como No Cumple será desmarcado' : 'Esto desmarcará todos los defectos de tipo No Applica.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.naCheckboxTargets.forEach((checkbox) => {
                    checkbox.checked = isChecked;
                    // Disparar eventos 'change' para notificar a otros controllers si es necesario
                    checkbox.dispatchEvent(new Event('change'));
                });
            } else {
                // Revertir el estado del checkbox principal
                headerCheckbox.checked = !isChecked;
            }
        });
    }
}
