#!/usr/bin/env python3
import os
import sys
import json
import argparse
import re
from docx import Document
from docx.shared import Inches
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.table import Table
from docx.text.paragraph import Paragraph

def add_paragraph_after(paragraph):
    new_p = OxmlElement('w:p')
    paragraph._p.addnext(new_p)
    return Paragraph(new_p, paragraph._parent)

def add_table_after(paragraph, doc, rows=0, cols=2):
    tmp_table = doc.add_table(rows=rows, cols=cols)
    tbl_elem = tmp_table._tbl
    doc.element.body.remove(tbl_elem)
    paragraph._p.addnext(tbl_elem)
    return Table(tbl_elem, paragraph._parent)

def remove_table_header_formatting(table):
    for row in table.rows:
        for cell in row.cells:
            tcPr = cell._element.get_or_add_tcPr()
            shading = OxmlElement('w:shd')
            shading.set(qn('w:fill'), "FFFFFF")
            tcPr.append(shading)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--folder", required=True, help="Directorio donde están el DOCX, mapping.json e imágenes")
    parser.add_argument("--docx",   required=True, help="Nombre del archivo DOCX dentro de --folder")
    parser.add_argument("--token",  required=True, help="Texto a buscar/reemplazar (p.ej. 'CODIGO IMAGEN 24123123')")
    args = parser.parse_args()

    folder_path = args.folder
    docx_name   = args.docx
    token       = args.token

    docx_path = os.path.join(folder_path, docx_name)
    mapping_path = os.path.join(folder_path, "mapping.json")
    signatures_path = os.path.join(folder_path, "signatures.json")

    doc = Document(docx_path)

    signatures_data = {}
    if os.path.exists(signatures_path):
        with open(signatures_path, "r", encoding="utf-8") as f:
            signatures_data = json.load(f)

    def process_signatures(paragraphs):
        pattern = r'(\{\{firma_admin\}\}|\{\{firma_inspector\}\})'
        for paragraph in paragraphs:
            text = paragraph.text
            if "{{firma_admin}}" not in text and "{{firma_inspector}}" not in text:
                continue

            alignment = paragraph.alignment
            parts = re.split(pattern, text)
            paragraph.clear()

            for part in parts:
                if part == "{{firma_admin}}":
                    img_filename = signatures_data.get("{{firma_admin}}")
                    if img_filename:
                        img_path = os.path.join(folder_path, img_filename)
                        if os.path.exists(img_path):
                            try:
                                run = paragraph.add_run()
                                run.add_picture(img_path, width=Inches(1.8))
                            except Exception as e:
                                print(f"Error cargando firma admin: {e}")

                elif part == "{{firma_inspector}}":
                    sigs = signatures_data.get("{{firma_inspector}}", [])
                    img_filename = None
                    if len(sigs) > 0:
                        img_filename = sigs.pop(0)

                    if img_filename:
                        img_path = os.path.join(folder_path, img_filename)
                        if os.path.exists(img_path):
                            try:
                                run = paragraph.add_run()
                                run.add_picture(img_path, width=Inches(1.8))
                            except Exception as e:
                                print(f"Error cargando firma inspector: {e}")
                else:
                    if part:
                        paragraph.add_run(part)

            # Restauramos la alineación original
            if alignment is not None:
                paragraph.alignment = alignment

    process_signatures(doc.paragraphs)
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                process_signatures(cell.paragraphs)
    # -------------------------------------

    if not os.path.exists(mapping_path):
        for paragraph in doc.paragraphs:
            if token in paragraph.text:
                paragraph.text = paragraph.text.replace(token, "")
        doc.save(docx_path)
        return

    with open(mapping_path, "r", encoding="utf-8") as f:
        photos_mapping = json.load(f)

    if not photos_mapping:
        for paragraph in doc.paragraphs:
            if token in paragraph.text:
                paragraph.text = paragraph.text.replace(token, "")
        doc.save(docx_path)
        return

    inserted = False
    for paragraph in doc.paragraphs:
        if token in paragraph.text:
            paragraph.text = paragraph.text.replace(token, "")

            new_paragraph = add_paragraph_after(paragraph)
            table = add_table_after(new_paragraph, doc, rows=0, cols=2)
            remove_table_header_formatting(table)

            for i in range(0, len(photos_mapping), 2):
                row_img  = table.add_row()
                row_text = table.add_row()

                fn1 = photos_mapping[i]["filename"]
                tx1 = photos_mapping[i]["text"]
                p_img1 = row_img.cells[0].paragraphs[0]
                p_img1.paragraph_format.keep_with_next = True
                run1 = p_img1.add_run()
                run1.add_picture(os.path.join(folder_path, fn1), width=Inches(2))

                p_txt1 = row_text.cells[0].paragraphs[0]
                p_txt1.add_run(tx1)

                if i+1 < len(photos_mapping):
                    fn2 = photos_mapping[i+1]["filename"]
                    tx2 = photos_mapping[i+1]["text"]
                    p_img2 = row_img.cells[1].paragraphs[0]
                    p_img2.paragraph_format.keep_with_next = True
                    run2 = p_img2.add_run()
                    run2.add_picture(os.path.join(folder_path, fn2), width=Inches(2))

                    p_txt2 = row_text.cells[1].paragraphs[0]
                    p_txt2.add_run(tx2)

            inserted = True
            break

    doc.save(docx_path)

if __name__ == "__main__":
    main()