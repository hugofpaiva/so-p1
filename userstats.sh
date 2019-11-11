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

# Usage - Como se usa o script
function usage(){
   echo "BURRO"
}



#Tratamento de opções
# -z: vai testar se o "$1" é uma string nula ou não. Se for uma string nula, é executado.
#    [ -z "$1" ] ) 
if [ -z "$1" ]#Este if verifica se é passada algum arguemto ou não
then 
   echo "Nenhum argumento ou opção"
   exit
else

   while getopts g:u:s:e:f:rntai option; do # As opções são passadas todas a seguir ao getopts. Se tiver ":" quer dizer que aceita argumentos. O "${OPTARG}" são os argumentos
      case "${option}" in
         g) echo "A opção g foi ativada." ;;
         u) argumento_b="${OPTARG}" ;;
         s) recebi_c=1 ;;
         e) recebi_d=1 ;;
         f) echo "O script vai ler do ficheiro ${OPTARG}";;
         r) ;;
         n) ;;
         t) ;;
         a) ;;
         i) ;;
         *)
               echo "*"
               ;;
      esac
      shift $((OPTIND-1))
   done

   if [ $OPTIND -eq 1 ] #Este if corre se não houve nenhuma opção mas forem passado argumentos
   then
      echo "Nenhuma opção mas foram passado argumentos"
   fi

  fi


# Este shitf vai fazer desaparecer dos argumentos $1, $2, ... as opções e argumentos passado ao getopts

#Logo, ao fazer echo "$1" vai-me dar os outros argumentos não utilizados em getopts
#echo "$1"