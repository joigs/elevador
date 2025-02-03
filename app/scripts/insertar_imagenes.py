#!/usr/bin/env python3
import os
import sys
import json
import argparse
from docx import Document
from docx.shared import Inches
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.table import Table
from docx.text.paragraph import Paragraph
from docx.enum.text import WD_PARAGRAPH_ALIGNMENT

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

def set_table_borders(table):

    for row in table.rows:
        for cell in row.cells:
            tcPr = cell._element.get_or_add_tcPr()
            borders = OxmlElement('w:tcBorders')
            for border_name in ['top', 'left', 'bottom', 'right']:
                border = OxmlElement(f'w:{border_name}')
                border.set(qn('w:val'), 'single') 
                border.set(qn('w:sz'), '4')    
                border.set(qn('w:space'), '0')   
                border.set(qn('w:color'), '000000')  
                borders.append(border)
            tcPr.append(borders)

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

    doc = Document(docx_path)

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
            remove_table_header_formatting(table)  # Elimina formato de encabezado
            set_table_borders(table)  # Agrega bordes manualmente

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
