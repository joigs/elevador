
import { Controller } from "@hotwired/stimulus"


//controlador para que solo se guarden las fallas que esten marcadas.
//tambien que el codigo de la falla donde se sube la foto se guarde solo si se sube una foto


export default class extends Controller {
    static targets = ["fail", "nullCondition", "level", "point", "code", "comment", "photo", "photoCode", "priority", "number"]

    connect() {
        this.toggleFields();
        this.photoTargets.forEach((photoInput) => {
            photoInput.addEventListener('change', (event) => this.handleFileUpload(event));
        });
    }

    toggleNullCondition(event) {
        const checkBoxIndex = this.nullConditionTargets.indexOf(event.target);
        const correspondingFailCheckBox = this.failTargets[checkBoxIndex];

        if(event.target.checked) {
            correspondingFailCheckBox.checked = false;
        }

        this.toggleFields();
    }

    toggleFields() {
        this.failTargets.forEach((failTarget, index) => {
            const isChecked = failTarget.checked;
            const photoInput = this.photoTargets[index];
            const codeInput = this.codeTargets[index];
            const photoCodeInput = this.photoCodeTargets[index];
            const levelInput = this.levelTargets[index];
            const pointInput = this.pointTargets[index];
            const commentInput = this.commentTargets[index];
            const priorityInput = this.priorityTargets[index];
            const numberInput = this.numberTargets[index];

            const hasUploadedPhoto = photoInput.files && photoInput.files.length > 0;

            const shouldEnable = isChecked || hasUploadedPhoto;
            photoInput.disabled = !shouldEnable;
            codeInput.disabled = !shouldEnable;
            levelInput.disabled = !shouldEnable;
            pointInput.disabled = !shouldEnable;
            commentInput.disabled = !shouldEnable;
            priorityInput.disabled = !shouldEnable;
            numberInput.disabled = !shouldEnable;

            photoCodeInput.disabled = !hasUploadedPhoto;
        });
    }

    toggle(event) {
        const checkBoxIndex = this.failTargets.indexOf(event.target);
        const correspondingNullConditionCheckBox = this.nullConditionTargets[checkBoxIndex];

        if(event.target.checked) {
            correspondingNullConditionCheckBox.checked = false;
        }

        this.toggleFields();
    }

    handleFileUpload(event) {
        const input = event.target;
        if(input.files.length > 0) {
            const photoInputIndex = this.photoTargets.indexOf(input);
            const photoCodeInput = this.photoCodeTargets[photoInputIndex];
            if (photoCodeInput) {
                photoCodeInput.disabled = false;
            }
        }
    }
}
