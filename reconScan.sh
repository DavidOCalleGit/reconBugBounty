#!/bin/bash


# Uso: Este script va a realizar un recon de subdominios para su posterior uso en un
# programa de bugbounty.


# Colors
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
end='\e[0m'

# Verifica que se le han pasado los parametros necesarios.
if [ $# -ne 2 ]; then
    echo -e "${red}[-] Uso: $0 <dominio> <programa>${end}"
    exit 1
fi
# Asignar variables
dominios="$1"
programa="$2"
fecha=$(date -I)

# Crear directorio para guardar los resultados
if [ ! -d "$programa" ]; then
    mkdir $programa && cd $programa
    echo -e "\n${green}[+] Directorio creado correctamente.${end}"
fi


# Realizar el recon de subdominios con assetfinder y subfinder, fusionar los resultados y eliminar duplicados.
echo -e "\n${yellow}[*] Realizando recon de subdominios...${end}"
subfinder -dL $dominios -o subfinder$fecha.txt
cat $dominios | assetfinder --subs-only $dominios | tee -a assetfinder$fecha.txt
# Fusiona y desecha los duplicados
cat *.txt | sort -u > subdomains$fecha.txt
find . -type f -not -name "subdomains$fecha.txt" -delete
echo -e "${green}\n[+] Recon de subdominios finalizado.${end}"
echo -e "${green}[+] Resultados guardados en $directorio/subdomains$fecha.txt${end}"

# Comprobar si los dominios obtenidos están activo con httpx, se guardan con su status code y cname.
echo -e "\n${yellow}[*] Comprobando si los dominios están activos...${end}"
cat subdomains$fecha.txt | httpx -sc -cname | tee -a alive$fecha.txt
echo -e "${green}[+] Comprobación de dominios finalizada.${end}"
echo -e "${green}[+] Resultados guardados en $directorio/alive$fecha.txt${end}"

# Realizar la busqueda en getallurls(gau) de endpoints en los dominios activos.
echo -e "\n${yellow}[*] Realizando busqueda de endpoints...${end}"
mkdir gauDir
cat alive$fecha.txt | gau -blacklist jpg,png,gif --subs | tee -a gauDir/endpoints$fecha.txt
echo -e "${green}\n[+] Busqueda de endpoints finalizada.${end}"
echo -e "${green}[+] Resultados guardados en $directorio/gauDir/endpoints$fecha.txt${end}"

# Busqueda de paramatros en los endpoints encontrados.
cat gauDir/endpoints$fecha.txt | sort -u | unfurl --unique keys | tee -a gauDir/params$fecha.txt
echo -e "${green}\n[+] Parametros encontrados guardados en $directorio/gauDir/params$fecha.txt${end}"

# Filtrar archivos .js .php .aspx .jsp .json
cat gauDir/endpoints$fecha.txt | grep -E '\.js' | tee -a gauDir/filesJS$fecha.txt
cat gauDir/endpoints$fecha.txt | grep -E '\.php' | tee -a gauDir/filesPHP$fecha.txt
cat gauDir/endpoints$fecha.txt | grep -E '\.aspx' | tee -a gauDir/filesASPX$fecha.txt
cat gauDir/endpoints$fecha.txt | grep -E '\.jsp' | tee -a gauDir/filesJSP$fecha.txt
cat gauDir/endpoints$fecha.txt | grep -E '\.json' | tee -a gauDir/filesJSON$fecha.txt
echo -e "${green}[+] Archivos .js encontrados guardados en $directorio/gauDir"

# Busqueda de parametros sensibles en los endpoints encontrados.
cat gauDir/endpoints$fecha.txt | sort -u | grep url= | tee -a gauDir/sensitiveURL$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep key= | tee -a gauDir/sensitiveKEY$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep secret= | tee -a gauDir/sensitiveSECRET$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep token= | tee -a gauDir/sensitiveTOKEN$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep pass= | tee -a gauDir/sensitivePASS$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep pwd= | tee -a gauDir/sensitivePWD$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep api= | tee -a gauDir/sensitiveAPI$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep auth= | tee -a gauDir/sensitiveAUTH$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep code= | tee -a gauDir/sensitiveCODE$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep secret= | tee -a gauDir/sensitiveSECRET$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep path= | tee -a gauDir/sensitivePATH$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep site= | tee -a gauDir/sensitiveSITE$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep data= | tee -a gauDir/sensitiveDATA$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep root= | tee -a gauDir/sensitiveROOT$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep dir= | tee -a gauDir/sensitiveDIR$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep conf= | tee -a gauDir/sensitiveCONF$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep config= | tee -a gauDir/sensitiveCONFIG$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep debug= | tee -a gauDir/sensitiveDEBUG$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep test= | tee -a gauDir/sensitiveTEST$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep check= | tee -a gauDir/sensitiveCHECK$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep view= | tee -a gauDir/sensitiveVIEW$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep display= | tee -a gauDir/sensitiveDISPLAY$fecha.txt
cat gauDir/endpoints$fecha.txt | sort -u | grep show= | tee -a gauDir/sensitiveSHOW$fecha.txt

find gauDir/ -type f -size 0 -delete

echo -e "${green}\n[+] Parametros sensibles encontrados guardados en $directorio/gauDir${end}"

# Busqueda de endpoints js con subjs desde el archivo alive$fecha.txt y guardado en el direcctorio jsDir.
echo -e "\n${yellow}[*] Realizando busqueda de endpoints js...${end}"
mkdir jsDir
cat alive$fecha.txt | subjs | tee -a jsDir/jsEndpoints$fecha.txt
echo -e "${green}[+] Busqueda de endpoints js finalizada.${end}"
echo -e "${green}[+] Resultados guardados en $directorio/jsDir/jsEndpoints$fecha.txt${end}"
