// app/javascript/controllers/fecha_venta_convenio_controller.js
import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";
import { Spanish } from "flatpickr/dist/l10n/es";

flatpickr.localize(Spanish);

export default class extends Controller {
    static targets = ["input"];
    static values  = {
        minDate: String,
        maxDate: String
    };

    connect() {
        flatpickr(this.inputTarget, {
            dateFormat: "Y-m-d",
            altInput: true,
            altFormat: "d-m-Y",
            locale: "es",
            static: false,
            minDate: this.minDateValue || null,
            maxDate: this.maxDateValue || null
        });
    }
}
