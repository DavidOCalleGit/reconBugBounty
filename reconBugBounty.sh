#!/usr/bin/bash

# Colours
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
end="\e[0m"


# Banner
echo -e $yellow"
 ____  _____ ____ ___  _   _ 
|  _ \| ____/ ___/ _ \| \ | |
| |_) |  _|| |  | | | |  \| |
|  _ <| |__| |__| |_| | |\  |
|_| \_\_____\____\___/|_| \_|

By_dodecaneser
"$end

# Check arguments
if [ $# -lt 2 ]; then
 echo -e "${green}Para ejecutar el script me hacen falta los argumentos\n"
 echo -e "Usage: " 
 echo -e "\t$0 <program> <target>${end}"
 exit 1
else
 program=$1
 target=$2
fi

folder=$program-$(date '-I')
echo "$folder"

# Get Domains
mkdir -p $folder && cd $folder

cat $target | assetfinder --subs-only >> assetfinder_domains.txt
amass enum -df $target -passive -o ammas_passive_domains.txt
sort -u *_domains.txt -o subdomains.txt
cat subdomains.txt | rev | cut -d . -f 1-3 | rev | sort -u | tee root_subdomains.txt
cat *.txt | sort -u > domains.txt
find . -type f -not -name 'domains.txt' -delete

# Get Alive
cat domains.txt | httpx -sc -title -ip -o alive.txt
cat alive.txt | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" >alive.json

# Get GauPlus

mkdir GauPlus

cat alive.txt | gauplus > GauPlus/GauPlus.txt
cat GauPlus/GauPlus.txt | sort -u | unfurl --unique keys > GauPlus/paramlist.txt
cat GauPlus/GauPlus.txt | sort -u | grep -P "\w+\.js(\?|$)" | sort -u >GauPlus/jsurls.txt
cat GauPlus/GauPlus.txt | sort -u | grep -P "\w+\.php(\?|$)" | sort -u >GauPlus/phpurls.txt
cat GauPlus/GauPlus.txt | sort -u | grep -P "\w+\.aspx(\?|$)" | sort -u >GauPlus/aspxurls.txt
cat GauPlus/GauPlus.txt | sort -u | grep -P "\w+\.jsp(\?|$)" | sort -u >GauPlus/jspurls.txt
cat GauPlus/GauPlus.txt | sort -u | grep url= >GauPlus/open_url.txt
cat GauPlus/GauPlus.txt | sort -u | grep redirect= >GauPlus/open_redirect.txt
cat GauPlus/GauPlus.txt | sort -u | grep dest= >GauPlus/open_dest.txt
cat GauPlus/GauPlus.txt | sort -u | grep path= >GauPlus/open_path.txt
cat GauPlus/GauPlus.txt | sort -u | grep data= >GauPlus/open_data.txt
cat GauPlus/GauPlus.txt | sort -u | grep domain= >GauPlus/open_domain.txt
cat GauPlus/GauPlus.txt | sort -u | grep site= >GauPlus/open_site.txt
cat GauPlus/GauPlus.txt | sort -u | grep dir= >GauPlus/open_dir.txt
cat GauPlus/GauPlus.txt | sort -u | grep document= >GauPlus/document.txt
cat GauPlus/GauPlus.txt | sort -u | grep root= >GauPlus/open_root.txt
cat GauPlus/GauPlus.txt | sort -u | grep path= >GauPlus/open_path.txt
cat GauPlus/GauPlus.txt | sort -u | grep folder= >GauPlus/open_folder.txt
cat GauPlus/GauPlus.txt | sort -u | grep port= >GauPlus/open_port.txt
cat GauPlus/GauPlus.txt | sort -u | grep result= >GauPlus/open_result.txt

find GauPlus/ -size 0 -delete

# JS

mkdir jslinks

cat alive.txt | subjs >>jslinks/all_jslinks.txt

