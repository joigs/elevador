// app/javascript/controllers/image_resize_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["file"]

    async resizeImage(event) {
        const fileInput = event.target
        const file = fileInput.files[0]
        if (!file) return

        try {
            const resizedFile = await this.resizeFile(file)
            const dataTransfer = new DataTransfer()
            dataTransfer.items.add(resizedFile)
            fileInput.files = dataTransfer.files
        } catch (error) {
            console.error('Error resizing image:', error)
        }
    }

    resizeFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader()
            reader.onload = (readerEvent) => {
                const image = new Image()
                image.onload = () => {
                    const canvas = document.createElement('canvas')
                    const ctx = canvas.getContext('2d')
                    const width = 400
                    const height = 300
                    canvas.width = width
                    canvas.height = height
                    ctx.drawImage(image, 0, 0, width, height)

                    canvas.toBlob((blob) => {
                        if (blob) {
                            const resizedFile = new File([blob], file.name, {
                                type: file.type,
                                lastModified: Date.now(),
                            })
                            resolve(resizedFile)
                        } else {
                            reject(new Error('Canvas toBlob failed'))
                        }
                    }, file.type)
                }
                image.onerror = (error) => reject(error)
                image.src = readerEvent.target.result
            }
            reader.onerror = (error) => reject(error)
            reader.readAsDataURL(file)
        })
    }
}
