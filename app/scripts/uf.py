import requests
from datetime import datetime

def convertir_a_float(s):
    if ',' in s:
        s = s.replace('.', '')
        s = s.replace(',', '.')
        return float(s)
    elif s.count('.') > 1:
        partes = s.rsplit('.', 1)
        parte_entera = partes[0].replace('.', '')
        s = parte_entera + '.' + partes[1]
        return float(s)
    else:
        return float(s)

def obtener_valor_uf(fecha):
    url = f"https://valor-uf.cl/fetch_uf_data.php?fecha={fecha}"
    try:
        respuesta = requests.get(url)
        respuesta.raise_for_status()
        datos = respuesta.json()
        if fecha in datos:
            valor_str = datos[fecha]
            try:
                return convertir_a_float(valor_str)
            except ValueError:
                return None
        else:
            return None
    except requests.RequestException:
        return None

if __name__ == "__main__":
    fecha_actual = datetime.now().strftime('%Y-%m-%d')
    uf = obtener_valor_uf(fecha_actual)
    if uf is not None:
        print(uf)
