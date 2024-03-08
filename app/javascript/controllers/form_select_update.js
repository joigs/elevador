

//controlador que se encarga de actualizar los select dentro del form de inspeccion.
//SIN USO, AUN NO LO ELIMINO PORQUE ME DA MIEDO



document.addEventListener('turbo:load', function() {
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('change', function(event) {
            const principalSelect = event.target.closest('select[name="inspection[item_attributes][principal_id]"]');
            if (principalSelect) {
                const itemSelect = document.querySelector('select[name="inspection[item_attributes][identificador]"]');
                fetch(`/principals/${principalSelect.value}/items`)
                    .then(response => response.json())
                    .then(data => {
                        itemSelect.innerHTML = '';
                        data.forEach(item => {
                            const optionElement = document.createElement('option');
                            optionElement.value = item.identificador;
                            optionElement.textContent = item.identificador;
                            itemSelect.appendChild(optionElement);
                        });
                        const slimControllerElement = itemSelect.closest('[data-controller="slim"]');
                        if (slimControllerElement) {
                            const slimController = application.getControllerForElementAndIdentifier(slimControllerElement, "slim");
                            slimController.initializeSlimSelect();
                        }
                    })
                    .catch(error => console.error('No se pudieron obtener activos:', error));
            }
        });
    }
});
