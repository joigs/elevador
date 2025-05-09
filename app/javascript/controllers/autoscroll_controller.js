// app/javascript/controllers/autoscroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["box"]

    connect() {
        this.isDragging = false
        this.startX     = 0
        this.scrollLeft = 0
    }

    /* mousedown */
    start(e) {
        if (e.target.tagName !== "TH") return
        this.isDragging = true
        this.startX     = e.pageX - this.boxTarget.offsetLeft
        this.scrollLeft = this.boxTarget.scrollLeft
    }

    /* mousemove */
    move(e) {
        if (!this.isDragging) return
        e.preventDefault()
        const x     = e.pageX - this.boxTarget.offsetLeft
        const walk  = x - this.startX
        this.boxTarget.scrollLeft = this.scrollLeft - walk
    }

    /* mouseup / mouseleave */
    end() {
        this.isDragging = false
    }
}
