#!/bin/bash

echo "Bienvenido al buscador de máquinas HTB!"
echo "Uso:"
echo "-u -> Sincronicar listado de máquinas en local con listado en nube"
echo "-m -> Buscar por nombre de máquina"
echo "-i -> Buscar por IP de máquina"
echo "-d -> Buscar por la dificultad de la máquina"
echo "-o -> Buscar por sistema operativo de la máquina"
echo "-s -> Buscar por skills que se entrenan en la máquina"
echo "-y -> Obtener link de resolución de la máquina"
echo "-h -> Mostrar este panel de ayuda"

# variables globales
flags=(0 0 0 0 0 0 0 0)

# funciones
function actualizarArchivos() {
    echo "Sincronizando listado de máquinas..."
    # Lógica para sincronizar listado de máquinas
    curl https://htbmachines.github.io/bundle.js | js-beautify > machines_temp.js

    md5_original="$(md5sum bundle.js | awk '{print $1}')"
    md5_temp="$(md5sum machines_temp.js | awk '{print $1}')"
    #echo "MD5 Original: $md5_original"
    #echo "MD5 Temp: $md5_temp"

    if [[ $md5_original != $md5_temp ]]; then
        rm bundle.js
        mv machines_temp.js bundle.js
        echo "Listado de máquinas actualizado."
    else
        rm machines_temp.js
        echo "El listado de máquinas ya se encontraba actualizado."
    fi      
}

function buscarMaquinaPorNombre() {
    local name="$1"
    echo "Buscando máquina por nombre: $name"
    # Lógica para buscar máquina por nombre
    cat ./bundle.js | awk "/name: \"$name\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function buscarMaquinaPorIp() {
    local ip="$1"
    cat ./bundle.js | grep -B 3 -A 6 "ip: \"$ip\"" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function buscarMaquinaPorDificultad() {
    echo "Buscando máquinas por dificultad..."
    local difficulty="$1"
    echo "Dificultad seleccionada: $difficulty"
    cat ./bundle.js | grep "dificultad: \"$difficulty\"" -B 5 -A 4 | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ','
}

function buscarMaquinaPorOs(){
    echo "Buscando máquinas por sistema operativo..."
    local os="$1"
    echo "Sistema operativo seleccionado: $os"
    cat ./bundle.js | grep "so: \"${os}\"" -B 4 -A 5 | grep -vE "id:|sku:|resuelta:" | tr -d ',' | tr -d '"'
}

function buscarMaquinaPorSkills(){
    echo "Buscando máquinas por skills..."
    local skills="$1"
    echo "Skill seleccionada: $skills"
    cat ./bundle.js | grep skills -B 6 -A 2| grep "${skills}" -i -B 6 -A 2 | grep -vE "id:|sku:"
}

function obtenerEnclaceYoutube(){
    echo "Obteniendo enlace de YouTube..."
    local name="$1"
    cat ./bundle.js | grep -i "${name}" -A 8 | grep "youtube:" | awk '{print $2}' | tr -d '"' | tr -d ','
}

function buscarMaquinaPorOsYdificultad(){
    echo "Buscando máquinas por sistema operativo y dificultad..."
    local os="$1"
    local difficulty="$2"
    echo "Sistema operativo seleccionado: $os"
    echo "Dificultad seleccionada: $difficulty"
    cat ./bundle.js | grep "so: \"${os}\"" -B 5 -A5 -i | grep "dificultad: \"${difficulty}\"" -i -B 5 -A 5 | grep -vE "resuelta:|id:|sku:|lf.push" | tr -d '"' | tr -d ','
}

# leer parámetros
while getopts "um:i:d:o:s:y:h" opcion; do
    case $opcion in
        u) flags[0]=1 ;;
        m) flags[1]=1
              machine_name=$OPTARG ;;
        i) flags[2]=1
              machine_ip=$OPTARG ;;
        d) flags[3]=1
              machine_difficulty=$OPTARG ;;
        o) flags[4]=1
              machine_os=$OPTARG ;;
        s) flags[5]=1
              machine_skills=$OPTARG ;;
        y) flags[6]=1
              machine_name=$OPTARG ;;
        h) flags[7]=1 ;;
        *) echo "Opción inválida" ;;
    esac
done

# ejecutar funcionalidades según flags
echo "Flags seleccionados: ${flags[@]}"

if [[ ${flags[3]} -eq 1 && ${flags[4]} -eq 1 ]]; then
    echo "hola"
    buscarMaquinaPorOsYdificultad $machine_os $machine_difficulty
elif [[ ${flags[0]} -eq 1 ]]; then
    actualizarArchivos
elif [[ ${flags[1]} -eq 1 ]]; then
    buscarMaquinaPorNombre $machine_name
elif [[ ${flags[2]} -eq 1 ]]; then
    buscarMaquinaPorIp $machine_ip
elif [[ ${flags[3]} -eq 1 ]]; then
    buscarMaquinaPorDificultad $machine_difficulty
elif [[ ${flags[4]} -eq 1 ]]; then
    buscarMaquinaPorOs $machine_os
elif [[ ${flags[5]} -eq 1 ]]; then
    buscarMaquinaPorSkills $machine_skills
elif [[ ${flags[6]} -eq 1 ]]; then
    obtenerEnclaceYoutube $machine_name
elif [[ ${flags[7]} -eq 1 ]]; then
    echo "Uso:"
    echo "-u -> Sincronicar listado de máquinas en local con listado en nube"
    echo "-m -> Buscar por nombre de máquina"
    echo "-i -> Buscar por IP de máquina"
    echo "-d -> Buscar por la dificultad de la máquina"
    echo "-o -> Buscar por sistema operativo de la máquina"
    echo "-s -> Buscar por skills que se entrenan en la máquina"
    echo "-y -> Obtener link de resolución de la máquina"
    echo "-h -> Mostrar este panel de ayuda"
fi
# To do:
#- OS + difficulty