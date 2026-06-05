#!/bin/bash
set -euo pipefail

BASE="/var/www/certifica2/ChCerRepoFoto"
REMOTE="gdrive:RespaldoFotos"
ARCHIVOS="archivos.txt"

if [ ! -s "$ARCHIVOS" ]; then
  echo "Nada que subir"
  exit 0
fi

rclone copy --files-from "$ARCHIVOS" "$BASE" "$REMOTE" -P
rclone check --files-from "$ARCHIVOS" "$BASE" "$REMOTE" --one-way

echo "Subida verificada en $REMOTE"
