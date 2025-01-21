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


# Asignar variables
listaDominios="$1"
fecha="$(date -Idate)"
directorio="/liveDomains"


# Verificar si los archivos existen
if [ ! -f "listaDominios" ]; then
  echo -e "\n${red}[+]${end}${green} Error: El archivo '$listaDominios' no existe.${end}"
  exit 1
fi


# Verificar si el directorio existe.
if [ -d "$directorio" ]; then
    echo -e "\n${red}[+]${end}${green} El directorio $directorio existe.${end}"
else
    echo -e "\n${red}[+]${end}${green} El directorio $directorio no exite. Creandolo ... "
    mkdir -p "$directorio"
    echo -e "\n${red}[+]${end}${green} El directorio $directorio ya esta creado.${end}"
fi

# Procesar la lista de dominios.
echo -e "\n${red}[+]${end}${green} Procesando ... ${end}"
cat "$listaDominios" | httpx -sc -cname | tee -a $directorio/liveDomains${fecha}.txt

find . -type f .size 0 -delete

echo -e "\n${yellow}La busqueda ha finalizado, mira en liveDomains${fecha}.txt${end}"

