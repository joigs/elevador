// app/javascript/controllers/costly_download_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  confirm(event) {
    event.preventDefault()

    const href = this.element.getAttribute("href")
    if (!href) return

    Swal.fire({
      title: "Descarga costosa",
      text: "Este reporte es una operación costosa, puede tardar un rato en generarse y descargarse. No cierres esta página mientras se procesa. Recomendación: cuando termine, guarda una copia del archivo para no tener que descargarlo nuevamente.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#198754", // verde
      cancelButtonColor: "#6c757d",  // gris
      confirmButtonText: "Entendido, descargar",
      cancelButtonText: "Cancelar",
      customClass: { confirmButton: "mr-10" },
      allowOutsideClick: false,
      allowEscapeKey: true
    }).then((result) => {
      if (result.isConfirmed) {
        window.location.href = href
      }
    })
  }
}
