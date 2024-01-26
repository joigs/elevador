//al seleccionar una empresa mandante se actualiza el select de empresas menores, en form de items
document.addEventListener('DOMContentLoaded', function() {
    const principalSelect = document.querySelector('select[name="item[principal_id]"]');
    const minorSelect = document.querySelector('select[name="item[minor_id]"]');

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
});