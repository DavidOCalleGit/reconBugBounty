# Define colors
green="\e[32m"
yellow="\e[33m"
end="\e[0m"

# Define directories
directorio=$(pwd)
fecha=$(date +%Y%m%d)

# Function to search for sensitive parameters
search_sensitive_params() {
    local keywords=("api" "auth" "code" "secret" "path" "site" "data" "root" "dir" "conf" "config" "debug" "test" "check" "view" "display" "show")
    for keyword in "${keywords[@]}"; do
        cat gauDir/endpoints$fecha.txt | sort -u | grep "$keyword=" | tee -a gauDir/sensitive${keyword^^}$fecha.txt
    done
    find gauDir/ -type f -size 0 -delete
    echo -e "${green}\n[+] Parametros sensibles encontrados guardados en $directorio/gauDir${end}"
}

# Function to search for JS endpoints
search_js_endpoints() {
    echo -e "\n${yellow}[*] Realizando busqueda de endpoints js...${end}"
    mkdir -p jsDir
    cat alive$fecha.txt | subjs | tee -a jsDir/jsEndpoints$fecha.txt
    echo -e "${green}[+] Busqueda de endpoints js finalizada.${end}"
    echo -e "${green}[+] Resultados guardados en $directorio/jsDir/jsEndpoints$fecha.txt${end}"
}

# Function to search for parameters in JS endpoints
search_js_params() {
    echo -e "\n${yellow}[*] Buscando parametros en los endpoints js...${end}"
    mkdir -p jsDir/params
    cat jsDir/jsEndpoints$fecha.txt | paramspider -d | tee -a jsDir/params/params$fecha.txt
    cat jsDir/jsEndpoints$fecha.txt | linkfinder -i | tee -a jsDir/params/links$fecha.txt
    echo -e "${green}[+] Parametros encontrados en los endpoints js guardados en $directorio/jsDir/params${end}"
}

# Main script execution
search_sensitive_params
search_js_endpoints
search_js_params