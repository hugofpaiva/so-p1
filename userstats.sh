#!/bin/bash

# path="/var/log/wtmp"
path="last.txt"

# Arrays para guardar users e a sua informaçao
users=()
declare -A userinfo=()

# Leitura de ficheiro:
function read_file() {
   while IFS= read -r line; do
      file_array+=("$line")
   done <"$path"

}

# Usage das opções - Como se usa o script
function usage() {
   echo "Usage: $0 -g [grupo] -u [nome] -s [data1] -p [data2] -r -n -t -a -i"
   echo ""
   echo "[grupo] = Grupo de utilizadores"
   echo "[nome] = Nome dos utilizadores"
   echo "[data1] = Data de início da sessão a partir da qual as sessões devem ser consideradas"
   echo "[data2] = Data de início de sessão a partir da qual as sessões não devem ser consideradas"
   echo ""
   echo "Todas estas opções são opcionais, sendo que o script corre sem nenhuma opção."
   echo ""
   exit
}

# Tratamento de dados
function getUsers(){
   users=$(last -f cenas | awk '{print $1}' | sort -u | head -n -1 | sort | sed '/reboot/d' | grep -v '^$'z1)   
   users=$(echo $users | tr " " "\n")
}

function calcTime(){
   # 0x:xx / 00:xx / 00:0x / xx:xx          - length 5
   # 1+0x:xx / 1+00:xx / 1+00:0x / 1+xx:xx  - length 7
   time=$1

   # Calcular tempo em minutos
   if (( ${#time} == 7)); then
      minlogged=$(echo $time | tr '+' ':' | awk -F: '{ print ($1 * 1440) + ($2 * 60) + $3 }')
   else
      minlogged=$(echo $time | awk -F: '{ print ($1 * 60) + $2 }')
   fi

   # Calcular o total
   total=$(($total + $minlogged))

   # Calcular máximo e mínimo
   if (( minlogged < min )); then
      min=$minlogged
   fi

   if (( minlogged > max )); then
      max=$minlogged
   fi
}

function getInfo(){
   for user in $users; do
      sessions=$(last -f cenas | grep -o $user | wc -l)
      time=$(last -f cenas | grep $user | awk '{print $10}' | sed '/in/d' | sed 's/[)(]//g')

      min=3000000
      max=0
      total=0

      for t in $time; do
         calcTime "$t"
      done

      userinfo[$user]="${user} ${sessions} ${total} ${max} ${min}"

   done
}

# Tratamento de opções
if [ -z "$1" ]; then 
   getUsers
   getInfo

   for u in "${userinfo[@]}"; do
      printf "%s %s\n" "$u" "${userinfo[$u]}"
   done
   

exit

else

   while getopts g:u:s:e:f:rntai option; do
      case "${option}" in
      g)
         if [ ${2:0:1} == "-" ]; then 
            usage
         else
            echo "A opção g foi ativada."
            $(last)

         fi
         ;;
      u)
         echo ${2:0:1}
         if [ ${2:0:1} == "-" ]; then 
            usage
         else

            echo "ok"
            argumento_b="${OPTARG}"
         fi
         ;;
      s)
         if [ ${2:0:1} == "-" ]; then 
            usage
         else
            recebi_c=1
            echo "s"
         fi
         ;;
      e)
         if [ ${2:0:1} == "-" ]; then 
            usage
         else
            echo "e"
            recebi_d=1
         fi
         ;;
      f)
         if [ ${2:0:1} == "-" ]; then 
            usage
         else
            echo "O script vai ler do ficheiro ${OPTARG}"

            exit
         fi
         ;;
      r)
         echo "ok"
         ;;
      n) ;;
      t) ;;
      a) ;;
      i) ;;
      *)
         usage
         ;;
      esac
   done

   if [ $OPTIND -eq 1 ]; then
      echo " "
      echo "Nenhuma opção mas foram passado argumentos"
      echo " "
      usage
   fi

   shift $((OPTIND - 1))


fi
