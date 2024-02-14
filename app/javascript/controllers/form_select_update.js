/// app/javascript/controllers/form_select_update.js


//controlador que se encarga de actualizar los select dentro del form ade inspeccion.



document.addEventListener('turbo:load', function() {
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('change', function(event) {
            // Target the principal selection field specifically
            const principalSelect = event.target.closest('select[name="inspection[item_attributes][principal_id]"]');
            if (principalSelect) {
                // Define the item selector based on your form's structure
                const itemSelect = document.querySelector('select[name="inspection[item_attributes][identificador]"]');

                // Adjust the fetch URL to match your routes and controller action
                fetch(`/principals/${principalSelect.value}/items`)
                    .then(response => response.json())
                    .then(data => {
                        // Clear existing item options first
                        itemSelect.innerHTML = '<option value="">Select an item...</option>'; // Add a default "select" option

                        // Populate item select with options based on fetched data
                        data.forEach(item => {
                            const optionElement = document.createElement('option');
                            optionElement.value = item.identificador; // Set option value to item.identificador
                            optionElement.textContent = item.identificador; // Set option display text to item.identificador
                            itemSelect.appendChild(optionElement);
                        });
                    })
                    .catch(error => console.error('Failed to fetch items:', error)); // Handle any errors
            }
        });
    }
});
