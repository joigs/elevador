// app/javascript/controllers/old_toggle_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2';

export default class extends Controller {
    static targets = ["toggle", "disable", "header"];

    connect() {
        if (this.hasToggleTarget && this.toggleTarget.checked) {
            this.applyState(true);
        }
    }

    confirmToggle(event) {
        const isChecked = event.target.checked;
        const headerCheckbox = event.target;

        if (!isChecked) {
            this.applyState(false);
            return;
        }

        Swal.fire({
            title: '¿Estás seguro?',
            text: 'Esto desmarcará todos los defectos de esta sección (incluyendo los marcados como No Aplica) y eliminará las fotos cargadas.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            customClass: {
                confirmButton: 'mr-10'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                this.applyState(true);
            } else {
                headerCheckbox.checked = false;
            }
        });
    }

    applyState(isOld) {
        this.disableTargets.forEach((checkbox) => {
            if (isOld) {
                if (checkbox.checked) {
                    checkbox.checked = false;
                    checkbox.dispatchEvent(new Event('change'));
                }
                checkbox.disabled = true;
            } else {
                checkbox.disabled = false;
            }
        });

        if (this.hasHeaderTarget) {
            if (isOld) this.headerTarget.checked = false;
            this.headerTarget.disabled = isOld;
        }
    }
}