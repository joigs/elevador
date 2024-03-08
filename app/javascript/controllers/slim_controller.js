// app/javascript/controllers/slim_select_controller.js

import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

//controlador para el campo de selección con barra de busqueda
export default class extends Controller {
  connect() {
    this.slimSelect = new SlimSelect({
      select: this.element
    });
  }

  disconnect() {
    this.slimSelect.destroy();
  }

  update(event) {
    const options = event.detail.options;
    this.slimSelect.setData(options);
  }
}
