import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

//controlador para eliminar mensajes

export default class extends Controller {
  confirm(event) {
    event.preventDefault()
    const form = this.element

    Swal.fire({
      title: '¿Estás seguro?',
      text: "¿Estás seguro de que quieres eliminar esta foto?",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#d33',
      cancelButtonColor: '#3085d6',
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar',
      customClass: {
        confirmButton: 'mr-10'  // Aplica margen a la derecha del botón de confirmación
      }
    }).then((result) => {
      if (result.isConfirmed) {
        form.submit()
      }
    })
  }
}
