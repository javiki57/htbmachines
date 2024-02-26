#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!]Saliendo...[!]${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+] ${endColour}Uso:"
  echo -e "\t${purpleColour}m)${endColour} Buscar por un nombre de máquina"
  echo -e "\t${purpleColour}i)${endColour} Buscar por dirección IP"
  echo -e "\t${purpleColour}s)${endColour} Buscar por skills"
  echo -e "\t${purpleColour}c)${endColour} Buscar por certificaciones"
  echo -e "\t${purpleColour}o)${endColour} Muestra las máquinas del sistema operativo introducido"
  echo -e "\t${purpleColour}u)${endColour} Actualiza los archivos necesarios"
  echo -e "\t${purpleColour}y)${endColour} Obtener el enlace de YouTube"
  echo -e "\t${purpleColour}d)${endColour} Obtener las máquinas de la dificultad deseada"
  echo -e "\t${purpleColour}h)${endColour} Muestra este panel de ayuda"
}

function searchMachine(){
  machineName="$1"
  
  machineCheck="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | sed 's/^ *//' | sed 's/^[^:]*:/\\033[0;31m&\\033[0m/g' | tr -d '"')"

  if [ ! "$machineCheck" ]; then
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  
  else
  echo -e "\n${yellowColour}[+]${endColour} Listando las propiedades de la máquina ${blueColour}$machineName${endColour}:\n"
  #cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | sed 's/^ *//'
  
  echo -e "$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | sed 's/^ *//' | sed 's/^[^:]*:/\\033[0;31m&\\033[0m/g' | tr -d '"')"

  fi
}

function updateFiles(){
  tput civis

  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour} Descargando archivos necesarios..."
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} Todos los archivos han sido descargados"
    tput cnorm

  else
    echo -e "\n${yellowColour}[+]${endColour} Comprobando si hay actualizaciones pendientes..."
    curl -s $main_url > bundleTemp.js
    js-beautify bundleTemp.js | sponge bundleTemp.js

    md5_temp_value=$(md5sum bundleTemp.js | awk '{print $1}')
    md5_original=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original" ]; then
      
      echo -e "\n${yellowColour}[+]${endColour} No hay actualizaciones, todo está al día"
      rm bundleTemp.js

    else

      echo -e "$\n{yellowColour}[+]${endColour} Los archivos han sido actualizados"
      rm bundle.js && mv bundleTemp.js bundle.js
  
    fi
    tput cnorm
  fi
  
}


function searchIP(){

  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | sed 's/,//')"
  
  if [ -z $machineName ]; then
    
    echo -e "\n${redColour}[!] No existe ninguna máquina con esa IP${endColour}"

  else

    echo -e "\n${yellowColour}[+]${endColour} La máquina correspondiente a la IP ${blueColour}$ipAddress${endColour} es ${purpleColour}$machineName${endColour}\n"

  fi
}

function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El enlace de la máquina${endColour} ${blueColour}$machineName${endColour} es ${redColour}$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | sed 's/^ *//' | grep youtube | awk '{print $2}')${endColour}\n"
  else
    echo -e "\n${redColour} [!] La máquina proporcionada no coincide con las resueltas${endColour}\n"
  fi
}

function getDifficulty(){
  difficulty="$1"

  result_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"

  if [ ! "$result_check" ]; then

    echo -e "\n${redColour}[!] No hay máquinas de la dificultad introducida${endColour}"

  else

    echo -e "\n${yellowColour}[+]${endColour} Representando las máquinas de dificultad ${blueColour}$difficulty${endColour}:\n\n$result_check\n"
    
  fi

}

function getOS(){
  os="$1"
  os_checker="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ ! "$os_checker" ]; then
  
    echo -e "\n${redColour}[!] No existe ninguna máquina cuyo sistema operativo es $os${endColour}"

  else
    echo -e "\n${yellowColour}[+]${endColour} Representando las máquinas ${purpleColour}$os${endColour}:\n"

    if [ "$os" == "Linux" ]; then

      echo -e "${redColour}$os_checker${endColour}"

    else

      echo -e "${blueColour}$os_checker${endColour}"

    fi

  fi
}

function getOSDifficultyMachines(){

  difficulty="$1"
  os="$2"
  check_result="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)"

  if [ "$check_result" ]; then

    echo -e "\n${yellowColour}[+]${endColour} Listando máquinas ${purpleColour}$os${endColour} de dificultad ${greenColour}$difficulty${endColour}:\n"

    if [ "$os" == "Linux" ]; then

      echo -e "${redColour}$check_result${endColour}"

    else

      echo -e "${blueColour}$check_result${endColour}"

    fi

  else

    echo -e "\n${redColour}[!] No existen máquinas $os de dificultad $difficulty\n"

  fi

}

function getSkill(){
  skill="$1"

  check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"'| column)"

  if [ "$check_skill" ]; then

    echo -e "\n${yellowColour}[+]${endColour} Representando las máquinas donde puedes practicar ${blueColour}$skill${endColour}\n${purpleColour}$check_skill${endColour}"

  else
    
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la skill $skill ${endColour}\n"

  fi

}


function getCert(){
  
  cert="$1"

  cert_checker="$(cat bundle.js | grep "like: *\"$cert\"*" -i -B 8 | grep "name: " | sed 's/^ *//' | tr -d "," | awk 'NF{print $NF}' | tr -d '"' | column)"

  if [ "$cert_checker" ]; then
  
    echo -e "\n${yellowColour}[+]${endColour} Mostrando las máquinas que podrían salirte en la certificación ${purpleColour}$cert${endColour}:\n${turquoiseColour}$cert_checker${endColour}"
    

  else
  
    echo -e "${redColour}[!] No existe ninguna máquina que se parezca a la certificación $cert${endColour}"
  
  fi

}

#Indicadores (solo números)
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0


while getopts "m:ui:y:d:o:s:c:h" arg; do

  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    c) cert="$OPTARG"; let parameter_counter+=8;;
    h) ;;

  esac

done

if [ $parameter_counter -eq 1 ]; then
  
  searchMachine $machineName

elif [ $parameter_counter -eq 2 ]; then
  
  updateFiles

elif [ $parameter_counter -eq 3 ]; then

  searchIP $ipAddress
    
elif [ $parameter_counter -eq 4 ]; then

  getYoutubeLink $machineName

elif [ $parameter_counter -eq 5 ]; then
  
  getDifficulty $difficulty

elif [ $parameter_counter -eq 6 ]; then

  getOS $os

elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then

  getOSDifficultyMachines $difficulty $os

elif [ $parameter_counter -eq 7 ]; then

  getSkill "$skill"

elif [ $parameter_counter -eq 8 ]; then

  getCert "$cert"

else
  
  helpPanel

fi
