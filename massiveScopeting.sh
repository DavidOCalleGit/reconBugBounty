#!/bin/bash

# Verificar que se pasen los parámetros necesarios
if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <lista_dominios>"
  exit 1
fi

# Asignar argumentos a variables.
lista_dominios="$1" # Archivo que contiene la lista de dominios.

# Verificar si los archivos/directorios existen
if [ ! -f "$lista_dominios" ]; then
  echo "Error: El archivo de lista '$lista_dominios' no existe."
  exit 1
fi

# Massive Scopeting
cat $lista_dominios | xargs -n1 -P35 bash -c 'j=$0; url="${j}"; curl -Lks -x http://127.0.0.1:8080 $url -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)" -m 4 1>/dev/null'

echo -e "\nProceso terminado, todos los subdominios en Burp"


