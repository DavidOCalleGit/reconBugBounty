#!/bin/bash

# Verificar que se pasen los parámetros necesarios
if [ "$#" -ne 3 ]; then
  echo "Uso: $0 <lista_elementos> <archivo_fuente> <directorio_salida>"
  exit 1
fi

# Parámetros: archivos de entrada y archivo de salida
archivo1=$1
archivo2=$2
salida=$3

# Verificar si los archivos existen
if [ ! -f "$lista_elementos" ]; then
  echo "Error: El archivo de lista '$lista_elementos' no existe."
  exit 1
fi

if [ ! -f "$archivo_fuente" ]; then
  echo "Error: El archivo fuente '$archivo_fuente' no existe."
  exit 1
fi

# Fusionar, ordenar y eliminar duplicados
cat "$archivo1" "$archivo2" | grep -v '$'| sort -u > "$salida"

echo "Archivos fusionados y guardados en: $salida"
