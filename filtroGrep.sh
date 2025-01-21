#!/bin/bash

# Con este script dada una lista de keys o paths obtenidos con UNFURL, filtrarlos y guardalos.

# Colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m]"
end="\033[0m"


# Verificar que se pasen los parámetros necesarios

if [ "$#" -ne 3 ]; then
  echo -e  "\n${red}[+]${end}${green} Uso: $0 <lista_elementos> <archivo_fuente> <directorio_salida>${end}"
  exit 1
fi

# Parámetros: archivo de lista, archivo fuente, directorio de salida
lista=$1
archivo=$2
salida=$3

# Crear el directorio de salida si no existe
mkdir -p "$salida"

# Leer cada línea del archivo de lista
while read -r elemento; do
  # Buscar el elemento y guardar los resultados en un archivo
  grep "$elemento" "$archivo" > "$salida/$elemento.txt"
done < "$lista"

echo -e "\n${red}[+]${end}${green} Búsquedas completadas. Resultados en el directorio: $salida ${end}"


