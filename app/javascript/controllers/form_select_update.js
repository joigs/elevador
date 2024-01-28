document.addEventListener('DOMContentLoaded', function() {
    const principalSelect = document.querySelector('select[name="item[principal_id]"]');
    const minorSelect = document.querySelector('select[name="item[minor_id]"]');

    if (principalSelect) {
        principalSelect.addEventListener('change', function() {
            fetch(`/principals/${this.value}/minors.json`)
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
        });
    } else {
        console.log('principalSelect is null');
    }
});