// app/javascript/controllers/image_resize_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["file"]

    async resizeImage(event) {
        // Si el usuario eligió “Imagen Original”, salimos inmediatamente
        if (window.resizeReduced === false) return

        const fileInput = event.target
        const file      = fileInput.files[0]
        if (!file) return

        try {
            const resizedFile   = await this.resizeFile(file)
            const dataTransfer  = new DataTransfer()
            dataTransfer.items.add(resizedFile)
            fileInput.files     = dataTransfer.files
        } catch (error) {
            console.error("Error al redimensionar la imagen:", error)
        }
    }

    resizeFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader()
            reader.onload = (e) => {
                const image = new Image()
                image.onload = () => {
                    const canvas = document.createElement("canvas")
                    const ctx    = canvas.getContext("2d")

                    const maxDim = 600
                    let { width, height } = image
                    const factor = maxDim / Math.max(width, height)
                    if (factor < 1) {
                        width  *= factor
                        height *= factor
                    }

                    canvas.width  = width
                    canvas.height = height
                    ctx.drawImage(image, 0, 0, width, height)

                    canvas.toBlob((blob) => {
                        if (blob) {
                            resolve(
                                new File([blob], file.name, {
                                    type: file.type,
                                    lastModified: Date.now(),
                                }),
                            )
                        } else {
                            reject(new Error("canvas.toBlob falló"))
                        }
                    }, file.type)
                }
                image.onerror = reject
                image.src     = e.target.result
            }
            reader.onerror = reject
            reader.readAsDataURL(file)
        })
    }
}
