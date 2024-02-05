import { Controller } from "stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
    // Define static value to fetch the URL from HTML data attributes.
    static values = { url: String };

    // Triggered when the Stimulus controller is connected to the DOM.
    connect() {
        this.initializeTomSelect();
    }

    // Triggered when the Stimulus controller is removed from the DOM.
    disconnect() {
        this.destroyTomSelect();
    }

    // Initialize the TomSelect dropdown with the desired configurations.
    initializeTomSelect() {
        // Return early if no element is associated with the controller.
        if (!this.element) return;

        // Construct URL for fetching data which comes from the static value.
        // https://tom-select.js.org/examples/remote/
        const url = `${this.urlValue}.json`;

        // Fetch data for the dropdown.
        const fetchData = (search, callback) => {
            fetch(url)
                .then(response => response.json())  // Convert response to JSON.
                .then(data => callback(data))       // Send data to TomSelect.
                .catch(() => callback());           // Handle any errors.
        };

        // Define custom rendering for dropdown options.
        // see: https://tom-select.js.org/examples/customization/
        const renderOption = (data, escape) => {
            return `
        <div>
          <span class="block">${escape(data.name)}</span>
          <span class="text-gray-400">${escape(data.email)}</span>
        </div>
      `;
        };

        // Create a new TomSelect instance with the specified configuration.
        // see: https://tom-select.js.org/docs/
        // value, label, search, placeholder, etc can all be passed as static values instead of hard-coded.
        this.select = new TomSelect(this.element, {
            plugins: ['remove_button'],
            valueField: 'identificador',
            labelField: 'identificador',
            searchField: ['identificador'],
            maxItems: 1,
            selectOnTab: true,
            placeholder: "Select user",
            closeAfterSelect: true,
            hidePlaceholder: false,
            preload: true,
            create: false,
            openOnFocus: true,
            highlight: true,
            sortField: { field: "identificador", direction: "asc" },
            load: fetchData,
            render: {
                option: renderOption
            }
        });
    }

    // Cleanup: Destroy the TomSelect instance when the controller is disconnected.
    destroyTomSelect() {
        if (this.select) {
            this.select.destroy();
        }
    }
}