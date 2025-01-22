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
if [ ! -f "$listaDominios" ]; then
  echo -e "\n${red}[+]${end}${green} Error: El archivo '$listaDominios' no existe.${end}"
  exit 1
fi

# Crear directorio para guardar los resultados de nombre cname
mkdir -p "cname"

# Dada una lista de dominios, obtener el nombre CNAME.
while IFS= read -r dominio; do
  # Obtener el nombre CNAME
  cname="$(dig +nocmd +short "$dominio" cname +noall +answer)"
  # Guardar el resultado en un archivo, pero solo el cname y se guarda el subdominio poniendo que no exite el cname.
  if [ -n "$cname" ]; then
    echo "$dominio: $cname" >> "cname/cname$fecha.txt"
    echo -e "${green}[+]${end}${yellow} $dominio: $cname${end}"
  else
    echo "$dominio: No existe CNAME" >> "cname/cname$fecha.txt"
    echo -e "${green}[+]${end}${yellow} $dominio:${end} ${red}No existe CNAME${end}"
  fi

done < "$listaDominios"