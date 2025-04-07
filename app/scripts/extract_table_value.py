import sys
import re
import argparse
from docx import Document

def extract_table_value(docx_path):
    doc = Document(docx_path)

    pattern = re.compile(r"\bu\.?f\.?\b", re.IGNORECASE)

    for table in doc.tables:
        for row in table.rows:
            for i, cell in enumerate(row.cells):
                texto_celda = cell.text.strip()

                if pattern.search(texto_celda):
                    if i + 1 < len(row.cells):
                        return row.cells[i+1].text.strip()
                    else:
                        return texto_celda

    sys.exit("No se encontró ningún texto 'UF' (en ninguna de sus variaciones) dentro de una tabla.")

def main():
    parser = argparse.ArgumentParser(
        description="Extrae el contenido de la celda siguiente a aquella donde aparezca UF en una tabla."
    )
    parser.add_argument("--docx", required=True, help="Ruta al archivo DOCX.")
    args = parser.parse_args()

    value = extract_table_value(args.docx)
    print(value)

if __name__ == "__main__":
    main()
