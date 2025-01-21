#!/bin/bash

# Colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m]"
end="\033[0m"

# Verificar que se pasen los parámetros necesarios
if [ "$#" -ne 1 ]; then
  echo -e "\n${red}[+]${end}${green} Uso: $0 <lista de dominios>${end}"
  exit 1
fi

# Asignar argumentos a variables
listaDominios="$1"
fecha="$(date -Idate)"

# Verificar si los archivos existen
if [ ! -f "listaDominios" ]; then
  echo -e "\n${red}[+]${end}${green} Error: El archivo '$listaDominios' no existe.${end}"
  exit 1
fi

# Procesar la lista de subdominos para listas los cnames

echo -e "\n${red}[+]${end}${green} Buscando...${end}"

cat $listaDominios | xargs -n1 -P500 bash -c 'j=$0; url="${j}"; dig +nocmd $url cname +noall +answer | tee -a CNAME.txt'
