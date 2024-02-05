document.addEventListener('DOMContentLoaded', (event) => {
    let principalSelect = document.getElementById('principalSelect');
    let minorSelect = document.getElementById('minorSelect'); // Assuming the id of the minor select element is 'minorSelect'

    if (principalSelect) {
        fetch(`/principals/${principalSelect.value}/minors.json`)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                minorSelect.innerHTML = '';
                data.forEach(minor => {
                    const option = document.createElement('option');
                    option.value = minor.id;
                    option.text = minor.name;
                    minorSelect.appendChild(option);
                });
            })
            .catch(error => {
                console.log('Fetch Error: ', error);
            });
    }
});