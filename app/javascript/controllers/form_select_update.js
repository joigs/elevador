document.addEventListener('turbo:load', function() {
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('change', function(event) {
            const principalSelect = event.target.closest('select[name="inspection[item_attributes][principal_id]"]');
            const minorSelect = document.querySelector('select[name="inspection[item_attributes][minor_id]"]');
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
        });
    } else {
        console.log('form is null');
    }
});