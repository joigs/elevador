import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["button"]

    submitAndRedirect(event) {
        event.preventDefault();
        const url = event.currentTarget.dataset.url;
        const form = this.element.closest('form');

        // Submit form via AJAX
        fetch(form.action, {
            method: 'POST',
            body: new FormData(form),
            headers: { 'X-CSRF-Token': document.querySelector("[name='csrf-token']").content },
            redirect: 'follow'
        })
            .then(response => {
                if (response.ok) {
                    window.location.href = url;
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'No se pudieron guardar los cambios.',
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
    }
}

//Si empieza a fallar cambiar por este stimulus, es lo mismo pero tiene para saber mas del error.
//
//
//import { Controller } from "@hotwired/stimulus"
//
// export default class extends Controller {
//   static targets = ["button"]
//
//   submitAndRedirect(event) {
//     event.preventDefault()
//     const url  = event.currentTarget.dataset.url
//     const form = this.element.closest("form")
//
//     fetch(form.action, {
//       method: "POST",
//       body:   new FormData(form),
//       headers: { "X-CSRF-Token": document.querySelector("[name='csrf-token']").content },
//       redirect: "follow"
//     })
//     .then(async (response) => {
//       if (response.ok) {
//         window.location.href = url
//         return
//       }
//
//       // intenta extraer detalles legibles
//       let errorMsg = `Código ${response.status} – ${response.statusText}`
//       try {
//         const ct = response.headers.get("content-type") || ""
//         if (ct.includes("application/json")) {
//           const json = await response.json()
//           errorMsg = json.message || JSON.stringify(json)
//         } else {
//           const text = await response.text()
//           if (text.trim().length) errorMsg = text.trim().slice(0, 500)
//         }
//       } catch (_) { /* deja errorMsg por defecto */ }
//
//       Swal.fire({
//         icon: "error",
//         title: "Error al guardar",
//         html: `<pre style="text-align:left">${errorMsg}</pre>`,
//         confirmButtonText: "Cerrar"
//       })
//     })
//     .catch((err) => {
//       Swal.fire({
//         icon: "error",
//         title: "Error de red",
//         html: `<pre style="text-align:left">${err.message}</pre>`,
//         confirmButtonText: "Cerrar"
//       })
//     })
//   }
// }