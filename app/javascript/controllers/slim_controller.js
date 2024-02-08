import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'
//import 'slim-select/dist/slimselect.css'

//Controlador para usar el plugin slim-select, que permite hacer busquedas en los select


// Connects to data-controller="slim"
export default class extends Controller {
  connect() {
    new SlimSelect({
      select: this.element
    })
  }
}
