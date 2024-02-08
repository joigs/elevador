import { Application } from "@hotwired/stimulus"

//import './form_select_update'
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
