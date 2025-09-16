// app/javascript/controllers/copy_inspection_controller.js
import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
    static values = {
        searchUrl: String,
        previewUrl: String,
        copyUrl: String,
        showJsonUrl: String,
        inspectionId: Number
    }

    static targets = [
        "backdrop", "modalPanel", "searchInput", "resultsBody",
        "copyBtn", "previewBtn", "summaryBox",
        "paginationTop", "paginationBottom"
    ]

    connect() {
        this.selectedId = null
        this._debounceTimer = null
        this.query = ""
        this.page = 1
        this.perPage = 20
        this._escHandler = (e) => { if (e.key === "Escape") this.closeModal() }
    }

    openModal() {
        this.backdropTarget.classList.remove("hidden")
        document.documentElement.classList.add("overflow-hidden")
        document.addEventListener("keydown", this._escHandler)

        this.selectedId = null
        this.query = ""
        this.page = 1
        this.searchInputTarget.value = ""
        this.resultsBodyTarget.innerHTML = ""
        this.summaryBoxTarget.innerHTML = ""
        this._setButtonsDisabled(true)

        this.fetchSearch()
    }

    closeModal() {
        this.backdropTarget.classList.add("hidden")
        document.documentElement.classList.remove("overflow-hidden")
        document.removeEventListener("keydown", this._escHandler)
    }

    maybeCloseOnOutside(event) {
        if (!this.modalPanelTarget.contains(event.target)) {
            this.closeModal()
        }
    }


    debouncedSearch() {
        clearTimeout(this._debounceTimer)
        this._debounceTimer = setTimeout(() => {
            this.query = this.searchInputTarget.value
            this.page = 1
            this.fetchSearch()
        }, 200)
    }

    async fetchSearch() {
        const url = new URL(this.searchUrlValue, window.location.origin)
        if (this.query) url.searchParams.set("q", this.query)
        url.searchParams.set("page", this.page)
        url.searchParams.set("per_page", this.perPage)

        const res = await fetch(url, { headers: { "Accept": "application/json" } })
        const { results, meta } = await this.safeJson(res)

        this.renderRows(results || [])
        this.renderPagination(meta || { page: 1, total_pages: 1, total_count: 0 })
    }

    renderRows(rows) {
        this.resultsBodyTarget.innerHTML = ""
        this.selectedId = null
        this._setButtonsDisabled(true)
        this.summaryBoxTarget.innerHTML = ""

        rows.forEach(r => {
            const tr = document.createElement("tr")
            tr.className = "border-t border-gray-800 hover:bg-gray-800/50"
            tr.innerHTML = `
        <td class="px-3 py-2">
          <input type="radio" name="selected_inspection" value="${r.id}">
        </td>
        <td class="px-3 py-2">${r.number}</td>
        <td class="px-3 py-2">${r.name || ""}</td>
        <td class="px-3 py-2">${r.place || ""}</td>
        <td class="px-3 py-2">${r.ins_date || ""}</td>
        <td class="px-3 py-2">${r.state || ""}</td>
        <td class="px-3 py-2">${r.item_identificador || ""}</td>
      `
            tr.querySelector('input[type="radio"]').addEventListener("change", () => {
                this.selectedId = r.id
                this._setButtonsDisabled(false)
                this.summaryBoxTarget.innerHTML = ""
            })
            this.resultsBodyTarget.appendChild(tr)
        })
    }

    renderPagination(meta) {
        const { page, total_pages, total_count } = meta
        const fmt = (where) => `
      <button class="px-2 py-1 rounded bg-gray-800 disabled:opacity-50"
              ${page <= 1 ? "disabled" : ""}
              data-action="click->copy-inspection#prevPage">«</button>
      <span> Página ${page} / ${total_pages} · ${total_count} resultado(s) </span>
      <button class="px-2 py-1 rounded bg-gray-800 disabled:opacity-50"
              ${page >= total_pages ? "disabled" : ""}
              data-action="click->copy-inspection#nextPage">»</button>
    `
        this.paginationTopTarget.innerHTML = fmt("top")
        this.paginationBottomTarget.innerHTML = fmt("bottom")
        this.totalPages = total_pages || 1
    }

    prevPage() {
        if (this.page > 1) {
            this.page -= 1
            this.fetchSearch()
        }
    }

    nextPage() {
        if (this.page < (this.totalPages || 1)) {
            this.page += 1
            this.fetchSearch()
        }
    }

    async showPreview() {
        if (!this.selectedId) return
        const url = new URL(this.previewUrlValue, window.location.origin)
        url.searchParams.set("selected_inspection_id", this.selectedId)

        const res = await fetch(url, { headers: { "Accept": "application/json" } })
        const data = await this.safeJson(res).catch(async (e) => {
            await Swal.fire({ icon: "error", title: "No se puede mostrar el resumen", text: e.message })
            throw e
        })

        if (data.error) {
            await Swal.fire({ icon: "error", title: "No se puede mostrar el resumen", text: data.error })
            return
        }

        console.groupCollapsed("[Copiar inspección] Snapshots (preview)")
        console.log("Estado inicial:", data.current_snapshot)
        console.log("Referencia:", data.source_snapshot)
        console.groupEnd()

        this._lastPreview = data

        const s = data.summary
        const j = (o) => JSON.stringify(o, null, 2)

        const maps = this._labelMaps()

        const toNice = (field) =>
            maps.report[field] ||
            maps.detail[field] ||
            maps.ladderDetail[field] ||
            this._humanizeEs(field)

        const reportLines = (s.report || []).map(row =>
            `- ${toNice(row.field)}:\n   actual: ${JSON.stringify(row.current)}\n   ref:    ${JSON.stringify(row.source)}\n   ${row.will_update ? "→ se actualizará" : "→ se mantiene"}`
        ).join("\n\n")

        const detailLines = (s.detail || []).map(row =>
            `- ${toNice(row.field)}:\n   actual: ${JSON.stringify(row.current)}\n   ref:    ${JSON.stringify(row.source)}\n   ${row.will_update ? "→ se actualizará" : "→ se mantiene"}`
        ).join("\n\n")
        const rnCurrent = this._renameArrayOfObjects(s.revision_nulls?.current, maps.revNulls, { strict: true })
        const rnSource  = this._renameArrayOfObjects(s.revision_nulls?.source,  maps.revNulls, { strict: true })

        const rcCurrent = this._renameArrayOfObjects(s.revision_colors?.current, maps.revColors, { strict: true, omit: ["color", "revision_type"] })
        const rcSource  = this._renameArrayOfObjects(s.revision_colors?.source,  maps.revColors, { strict: true, omit: ["color", "revision_type"] })

        const anCurrent = this._renameArrayOfObjects(s.anothers?.current, maps.anothers, { strict: true, omit: ["ruletype_id"] })
        const anSource  = this._renameArrayOfObjects(s.anothers?.source,  maps.anothers, { strict: true, omit: ["ruletype_id"] })
        const anCreate  = this._renameArrayOfObjects(s.anothers?.will_create, maps.anothers, { strict: true, omit: ["ruletype_id"] })


        const text = [
            "=== Detalle de la inspección ===",
            reportLines || "(sin diferencias / se mantienen)",
            "",
            "=== Información adicional del activo ===",
            detailLines || "(no se copiará el detalle o sin diferencias)",
            "",
            "=== Defectos No Aplican (actual) ===",
            j(rnCurrent || []),
            "",
            "=== Defectos No Aplican (referencia) ===",
            j(rnSource || []),
            "",
            "=== Defectos (actual) ===",
            j(rcCurrent || []),
            "",
            "=== Defectos (referencia) ===",
            j(rcSource || []),
            "",
            "=== Defectos Adicionales (actual) ===",
            j(anCurrent || []),
            "",
            "=== Defectos Adicionales (referencia) ===",
            j(anSource || []),
            "",
            "=== Defectos Adicionales (se crearán) ===",
            j(anCreate || [])
        ].join("\n")

        this.summaryBoxTarget.textContent = text
    }


    async confirmCopy() {
        if (!this.selectedId) return
        if (!this._lastPreview) await this.showPreview()

        const r1 = await Swal.fire({
            title: "¿Copiar desde la inspección seleccionada?",
            text: "Se reemplazarán/crearán datos según el resumen mostrado.",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Sí, continuar",
            cancelButtonText: "Cancelar",
            allowEscapeKey: true
        })
        if (!r1.isConfirmed) return

        const r2 = await Swal.fire({
            title: "Acción irreversible",
            text: "Esta acción NO se puede deshacer. ¿Confirmas la copia?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Sí, copiar",
            cancelButtonText: "Cancelar",
            allowEscapeKey: true
        })
        if (!r2.isConfirmed) return

        const formData = new FormData()
        formData.append("selected_inspection_id", this.selectedId)

        try {

            const copyRes = await fetch(this.copyUrlValue, {
                method: "PATCH",
                headers: { "X-CSRF-Token": this.csrfToken(), "Accept": "application/json" },
                body: formData
            })

            if (!copyRes.ok) {
                const txt = await copyRes.text()
                Swal.close()
                await Swal.fire({ icon: "error", title: "Error al copiar", text: this._shortHtmlError(txt) })
                return
            }

            const finalRes = await fetch(this.showJsonUrlValue, { headers: { "Accept": "application/json" } })
            let finalJson = null
            if (this._isJson(finalRes)) {
                finalJson = await finalRes.json()
            } else {
                console.warn("Respuesta de show no es JSON; se omiten logs finales.")
            }

            console.groupCollapsed("[Copiar inspección] Estados")
            console.log("Estado inicial:", this._lastPreview?.current_snapshot)
            console.log("Referencia:", this._lastPreview?.source_snapshot)
            console.log("Estado final:", finalJson)
            console.groupEnd()

            Swal.close()
            await Swal.fire({ icon: "success", title: "Copiado correctamente" })
            window.location.reload()
        } catch (e) {
            Swal.close()
            console.error(e)
            await Swal.fire({ icon: "error", title: "Error al copiar", text: e?.message || "Revisa la consola." })
        }
    }

    _setButtonsDisabled(disabled) {
        this.previewBtnTargets.forEach(btn => btn.disabled = disabled)
        this.copyBtnTargets.forEach(btn => btn.disabled = disabled)
    }

    _isJson(res) {
        const ct = res.headers.get("content-type") || ""
        return ct.includes("application/json")
    }

    async safeJson(res) {
        if (!res.ok) {
            const txt = await res.text()
            throw new Error(this._shortHtmlError(txt))
        }
        if (!this._isJson(res)) {
            const txt = await res.text()
            throw new Error(this._shortHtmlError(txt))
        }
        return res.json()
    }

    _shortHtmlError(txt) {
        const clean = txt.replace(/\s+/g, " ").slice(0, 300)
        return clean || "Respuesta no válida del servidor."
    }

    csrfToken() {
        const meta = document.querySelector('meta[name="csrf-token"]')
        return meta && meta.getAttribute("content")
    }



    _labelMaps() {
        const report = {
            fecha: "Fecha certificación anterior",
            vi_co_man_ini: "Vigencia contrato de mantención – Fecha inicio",
            vi_co_man_ter: "Vigencia contrato de mantención – Fecha término",
            ul_reg_man: "Último registro de mantención N°",
            urm_fecha: "Fecha Último registro de mantención",
            empresa_anterior: "Empresa certificadora anterior",
            ea_rol: "Rol empresa certificadora anterior",
            ea_rut: "RUT empresa certificadora anterior",
            empresa_mantenedora: "Empresa mantenedora",
            em_rol: "Rol empresa mantenedora",
            em_rut: "RUT empresa mantenedora",
            nom_tec_man: "Nombre técnico mantenedor",
            tm_rut: "RUT técnico mantenedor"
        }

        const detail = {
            detalle: "Detalle",
            marca: "Marca",
            modelo: "Modelo",
            n_serie: "N° de serie",
            mm_marca: "Motor Motriz – Marca",
            mm_n_serie: "Motor Motriz – N° de serie",
            potencia: "Potencia kW",
            capacidad: "Capacidad kg",
            personas: "Personas",
            ct_marca: "Cables de tracción – Marca",
            ct_cantidad: "Cables de tracción – Cantidad",
            ct_diametro: "Cables de tracción – Diámetro mm",
            medidas_cintas: "Cintas – Ancho mm",
            medidas_cintas_espesor: "Cintas – Espesor mm",
            rv_marca: "Regulador de velocidad – Marca",
            rv_n_serie: "Regulador de velocidad – N° de serie",
            paradas: "Paradas",
            embarques: "Embarques",
            sala_maquinas: "Sala de máquinas",
            velocidad: "Velocidad m/s",
            descripcion: "Descripción",
            rol_n: "Rol N°",
            numero_permiso: "N° de permiso de edificación",
            fecha_permiso: "Fecha de permiso de edificación",
            destino: "Destino",
            recepcion: "Recepción",
            empresa_instaladora: "Empresa instaladora",
            empresa_instaladora_rut: "RUT empresa instaladora",
            porcentaje: "% de ocupación"
        }

        const ladderDetail = {
            detalle: "Detalle",
            descripcion: "Descripción",
            rol_n: "Rol N°",
            numero_permiso: "N° de permiso de edificación",
            fecha_permiso: "Fecha de permiso de edificación",
            destino: "Destino",
            recepcion: "Recepción",
            empresa_instaladora: "Empresa instaladora",
            empresa_instaladora_rut: "RUT empresa instaladora",
            porcentaje: "% de ocupación",
            marca: "Marca",
            modelo: "Modelo",
            nserie: "N° de serie",
            mm_marca: "Motor Motriz – Marca",
            mm_nserie: "Motor Motriz – N° de serie",
            potencia: "Potencia kW",
            capacidad: "Capacidad kg",
            personas: "Personas",
            peldaños: "Peldaños mm",
            longitud: "Longitud",
            inclinacion: "Inclinación °",
            ancho: "Ancho mm",
            velocidad: "Velocidad m/s",
            fabricacion: "Año de fabricación",
            procedencia: "Procedencia"
        }

        const revNulls = {
            point: "Defecto",
            comment: "Comentario"
        }

        const revColors = {
            number: "Número",
            codes: "Código",
            points: "Texto defecto",
            levels: "Nivel",
            comment: "Comentario",
            section: "Sección",
            priority: "Prioridad"
        }

        const anothers = {
            point: "Texto defecto",
            code: "Código",
            level: "Nivel",
            ins_type: "Tipo defecto",
            section: "Sección"
        }

        return { report, detail, ladderDetail, revNulls, revColors, anothers }
    }

    _humanizeEs(str) {
        if (!str) return str
        const s = str.replace(/_/g, " ").trim()
        return s.charAt(0).toUpperCase() + s.slice(1)
    }

    _renameObjectKeys(obj, map, { strict = false, omit = [] } = {}) {
        if (!obj || typeof obj !== "object" || Array.isArray(obj)) return obj
        const out = {}
        for (const [k, v] of Object.entries(obj)) {
            if (omit.includes(k)) continue
            const label = (k in map) ? map[k] : (strict ? null : this._humanizeEs(k))
            if (label) out[label] = v
        }
        return out
    }

    _renameArrayOfObjects(arr, map, opts = {}) {
        if (!Array.isArray(arr)) return arr
        return arr.map(o => this._renameObjectKeys(o, map, opts))
    }


}
