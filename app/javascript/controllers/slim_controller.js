// app/javascript/controllers/slim_select_controller.js

import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

export default class extends Controller {
  connect() {
    this.slimSelect = new SlimSelect({
      select: this.element.querySelector('select')
    });
  }

  disconnect() {
    this.slimSelect.destroy();
  }

  update(event) {
    this.slimSelect.setData(event.detail.options);
  }
}
