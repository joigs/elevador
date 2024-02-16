// app/javascript/controllers/slim_select_controller.js

import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

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
    // Update the SlimSelect options with the new data
    const options = event.detail.options;
    this.slimSelect.setData(options);
  }
}
