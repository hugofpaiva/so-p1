#!/bin/bash

path="/var/log/wtmp"

file_array=() #Array onde vai ser guardado o ficheiro

# Leitura de ficheiro:
# -r: opção passada para o comando read que evita o "backslash escape" de ser interpretado
# IFS=:Opção antes do comando read que previne os espaços de serem cortados
function read_file(){
    while IFS= read -r line; do 
    file_array+=("$line")
    done < "$path"  #Vou buscar a variável path, logo uso $
}
read_file

# -z: vai testar se o "$1" é uma string nula ou não. Se for uma string nula, é executado.
#    [ -z "$1" ] ) 

# As opções são passadas todas a seguir ao getopts. Se tiver ":" quer dizer que aceita argumentos. O "${OPTARG}" são os argumentos

while getopts g:u:s:e:f:rntai option; do
     case "${option}" in
        g) echo "A opção A foi ativada." ;;
        u) argumento_b="${OPTARG}" ;;
        s) recebi_c=1 ;;
        e) recebi_d=1 ;;
        f) recebi_e=1 ;;
        r) ;;
        n) ;;
        t) ;;
        a) ;;
        i) ;;
     esac
  done