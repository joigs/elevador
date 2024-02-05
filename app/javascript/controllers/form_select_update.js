document.addEventListener('turbo:load', function() {
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('change', function(event) {
            const principalSelect = event.target.closest('select[name="inspection[item_attributes][principal_id]"]');
            const minorSelect = document.querySelector('select[name="inspection[item_attributes][minor_id]"]');
            const itemSelect = document.querySelector('select[name="inspection[item_attributes][item_id]"]');
            if (principalSelect) {
                fetch(`/principals/${principalSelect.value}/minors.json`)
                    .then(response => response.json())
                    .then(data => {
                        minorSelect.innerHTML = '';
                        data.forEach(minor => {
                            const option = document.createElement('option');
                            option.value = minor.id;
                            option.text = minor.name;
                            minorSelect.appendChild(option);
                        });
                    });
            }
            if (minorSelect){
                fetch(`/minors/${minorSelect.value}/items.json`)
                    .then(response => response.json())
                    .then(data => {
                        itemSelect.innerHTML = '';
                        data.forEach(item => {
                            const option = document.createElement('option');
                            option.value = item.identificador;
                            option.text = item.identificador;
                            itemSelect.appendChild(option);
                        });
                    });
            }
        });
    } else {
        console.log('form is null');
    }
});