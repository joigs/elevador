import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
    static targets = ["minorSelect"]
    change(event) {
        let principal = event.target.selectedOptions[0].value
        let target = this.minorSelectTarget.id // Change this line
        console.log(`principal: ${principal}, target: ${target}`)
        get(`/principals/minors?target=${target}&principal=${principal}`, {
            responseKind: "turbo-stream"
        })
    }
}
