#!/bin/bash


# Uso: Este script va a realizar un recon de subdominios para su posterior uso en un
# programa de bugbounty.


# Colors
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
end='\e[0m'

# Asignar variables
dominios=""
programa=""
fecha=$(date -I)

# Parse flags
while getopts "d:p:" opt; do
    case ${opt} in
        d )
            dominios=$OPTARG
            ;;
        p )
            programa=$OPTARG
            ;;
        \? )
            echo "Usage: cmd [-d] dominios [-p] programa"
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$dominios" ] || [ -z "$programa" ]; then
    echo "Usage: cmd [-d] dominios [-p] programa"
    exit 1
fi

# Crear directorio para guardar los resultados
if [ ! -d "$programa" ]; then
    mkdir $programa && cd $programa
    echo -e "\n${green}[+] Directorio creado correctamente.${end}"
fi

# Funciones

# Realizar el recon de subdominios con assetfinder y subfinder, fusionar los resultados y eliminar duplicados.
get_domain() {
    echo -e "\n${yellow}[*] Realizando recon de subdominios...${end}"
    subfinder -dL $dominios -o subfinder$fecha.txt
    cat $dominios | assetfinder --subs-only $dominios | tee -a assetfinder$fecha.txt
    # Fusiona y desecha los duplicados
    cat *.txt | sort -u > subdomains$fecha.txt
    find $programa/ -type f -not -name "subdomains$fecha.txt" -delete
    echo -e "${green}\n[+] Recon de subdominios finalizado.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/subdomains$fecha.txt${end}"
}

# Comprobar si los dominios obtenidos están activo con httpx, se guardan con su status code y cname.
alive_domains() {
    echo -e "\n${yellow}[*] Comprobando si los dominios están activos...${end}"
    cat subdomains$fecha.txt | httpx -sc -cname | tee -a aliveAll$fecha.txt
    cat aliveAll$fecha.txt | grep awk '{print $1}' | tee -a alive$fecha.txt
    echo -e "${green}[+] Comprobación de dominios finalizada.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/alive$fecha.txt${end}"
}

# Filtrado por Status Code
statusCode() {
    echo -e "\n${yellow}[*] Filtrando por Status Code...${end}"
    mkdir -p statusCodes
    cat aliveAll$fecha.txt | grep 200 | tee -a statusCodes/200$fecha.txt
    cat aliveAll$fecha.txt | grep 301 | tee -a statusCodes/301$fecha.txt
    cat aliveAll$fecha.txt | grep 302 | tee -a statusCodes/302$fecha.txt
    cat aliveAll$fecha.txt | grep 403 | tee -a statusCodes/403$fecha.txt
    cat aliveAll$fecha.txt | grep 404 | tee -a statusCodes/404$fecha.txt
    cat aliveAll$fecha.txt | grep 500 | tee -a statusCodes/500$fecha.txt
    echo -e "${green}[+] Filtrado por Status Code finalizado.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/statusCodes${end}"
}

# Realizar la busqueda en getallurls(gau) de endpoints en los dominios activos.
gauDomains() {
    echo -e "\n${yellow}[*] Realizando busqueda de endpoints...${end}"
    mkdir -p gauDir
    cat alive$fecha.txt | gau -blacklist jpg,png,gif --subs | tee -a gauDir/endpoints$fecha.txt
    echo -e "${green}\n[+] Busqueda de endpoints finalizada.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/gauDir/endpoints$fecha.txt${end}"
}

# Busqueda en endpoints$fecha.txt de posibles urls vulnerable a XSS, IDOR, SQLi, RCE, LFI con gf(Tomnomnom).
gfEndpoints() {
    echo -e "\n${yellow}[*] Buscando posibles vulnerabilidades en los endpoints...${end}"
    mkdir -p gfDir
    cat gauDir/endpoints$fecha.txt | gf xss | tee -a gfDir/xss$fecha.txt
    cat gauDir/endpoints$fecha.txt | gf idor | tee -a gfDir/idor$fecha.txt
    cat gauDir/endpoints$fecha.txt | gf sqli | tee -a gfDir/sqli$fecha.txt
    cat gauDir/endpoints$fecha.txt | gf rce | tee -a gfDir/rce$fecha.txt
    cat gauDir/endpoints$fecha.txt | gf lfi | tee -a gfDir/lfi$fecha.txt
    echo -e "${green}\n[+] Busqueda de vulnerabilidades finalizada.${end}"
}

# Busqueda de paramatros en los endpoints encontrados.
findParams() {
    echo -e "\n${yellow}[*] Buscando parametros en los endpoints...${end}"
    cat gauDir/endpoints$fecha.txt | sort -u | unfurl --unique keys | tee -a gauDir/params$fecha.txt
    echo -e "${green}\n[+] Parametros encontrados guardados en $directorio/gauDir/params$fecha.txt${end}"
}

# Filtrar archivos .js .php .aspx .jsp .json
filterFiles() {
    echo -e "\n${yellow}[*] Filtrando archivos .js .php .aspx .jsp .json...${end}"
    cat gauDir/endpoints$fecha.txt | grep -E '\.js' | tee -a gauDir/filesJS$fecha.txt
    cat gauDir/endpoints$fecha.txt | grep -E '\.php' | tee -a gauDir/filesPHP$fecha.txt
    cat gauDir/endpoints$fecha.txt | grep -E '\.aspx' | tee -a gauDir/filesASPX$fecha.txt
    cat gauDir/endpoints$fecha.txt | grep -E '\.jsp' | tee -a gauDir/filesJSP$fecha.txt
    cat gauDir/endpoints$fecha.txt | grep -E '\.json' | tee -a gauDir/filesJSON$fecha.txt
    echo -e "${green}[+] Archivos .js encontrados guardados en $directorio/gauDir${end}"
}

# Busqueda de parametros sensibles en los endpoints encontrados.
findSensitive() {
    echo -e "\n${yellow}[*] Buscando parametros sensibles en los endpoints...${end}"
    mkdir -p gauDir/sensitive
    cat gauDir/endpoints$fecha.txt | sort -u | grep email= | tee -a gauDir/sensitiveEMAIL$fecha.txt
    cat gauDir/endpoints$fecha.txt | sort -u | grep password= | tee -a gauDir/sensitivePASSWORD$fecha.txt
    cat gauDir/endpoints$fecha.txt | sort -u | grep user= | tee -a gauDir/sensitiveUSER$fecha.txt
    cat gauDir/endpoints$fecha.txt | sort -u | grep username= | tee -a gauDir/sensitiveUSERNAME$fecha.txt
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
}

# Busqueda de endpoints js con subjs desde el archivo alive$fecha.txt y guardado en el direcctorio jsDir.
findJs() {
    echo -e "\n${yellow}[*] Realizando busqueda de endpoints js...${end}"
    mkdir jsDir
    cat alive$fecha.txt | subjs | tee -a jsDir/jsEndpoints$fecha.txt
    echo -e "${green}[+] Busqueda de endpoints js finalizada.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/jsDir/jsEndpoints$fecha.txt${end}"
}

# Con la lista de endpoints js, se buscan parametros en los mismos con paramspider y linkfinder
findJsParams() {
    echo -e "\n${yellow}[*] Buscando parametros en los endpoints js...${end}"
    mkdir -p jsDir/params
    cat jsDir/jsEndpoints$fecha.txt | paramspider -d | tee -a jsDir/params/params$fecha.txt
    cat jsDir/jsEndpoints$fecha.txt | linkfinder -i | tee -a jsDir/params/links$fecha.txt
    echo -e "${green}[+] Parametros encontrados en los endpoints js guardados en $directorio/jsDir/params${end}"
}

# Main script execution
get_domain
alive_domains
statusCode
gauDomains
gfEndpoints
findParams
filterFiles
findSensitive
findJs
findJsParams

