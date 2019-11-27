#!/bin/bash

# Arrays para guardar users e a sua informaçao
users=()
declare -A argOpt=() #Array associativo onde são guardadas os argumento correspondentes às opções passadas
declare -A userInfo=()

# Usage das opções - Como se usa o script
function usage() {
   echo "Usage: $0 -g [grupo] -u [nome] -s [data1] -p [data2] -r -n -t -a -i"
   echo ""
   echo "[grupo] = Grupo de utilizadores"
   echo "[nome]  = Nome dos utilizadores"
   echo "[data1] = Data de início da sessão a partir da qual as sessões devem ser consideradas"
   echo "[data2] = Data de início de sessão a partir da qual as sessões não devem ser consideradas"
   echo ""
   echo "Todas estas opções são opcionais, sendo que o script corre sem nenhuma opção."
   echo ""
   exit
}

# Tratamento de opções
function args() {

   while getopts g:u:s:e:f:rntai option; do
      case "${option}" in
      g) #Seleção de utilizadores através do seu grupo
         if [ ${OPTARG:0:1} == "-" ]; then
            usage
         fi
         ;;
      u) #Seleção de utilizadores através do nome dos utilizadores
         if [ ${OPTARG:0:1} == "-" ]; then
            usage
         fi
         ;;
      s) #Seleção do período através da especificação da data a partir da qual as sessões são consideradas
         if [ ${OPTARG:0:1} == "-" ]; then
            usage
         fi
         ;;
      e) #Seleção do período através da especificação da data a partir da qual as sessões não são consideradas
         if [ ${OPTARG:0:1} == "-" ]; then
            usage
         fi
         ;;
      f) #Extração das informações a partir de um ficheiro distinto
         if [ ${OPTARG:0:1} == "-" ]; then
            usage
         fi
         ;;
      r | n | t | a | i) ;;
      *) #Opções não atribuidas pelo getopts
         usage
         ;;
      esac

      if [[ -z "$OPTARG" ]]; then
         argOpt[$option]="none"
      else
         argOpt[$option]=${OPTARG}
      fi
   done

   shift $((OPTIND - 1))

}

# Tratamento e leitura de dados

function getUsers() {
   if [[ -v argOpt[f] ]]; then #-v em declarative arrays vai verificar se o elemento a seguir está no array
      users=$(last -f "${argOpt['f']}" | awk '{if($10 !~ /in/) {print $1}}' | sort | uniq | sed '/reboot/d' | sed "/${argOpt['f']}/d")
   else
      # Filtrar users
      if [[ -v argOpt[u] ]]; then
         match="${argOpt['u']}"
         users=$(last | awk '{if($10 !~ /in/) {print $1}}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d' | grep $match)

      elif [[ -v argOpt[g] ]]; then
         group="${argOpt['g']}"
         users=$(last | awk '{if($10 !~ /in/) {print $1}}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d')

         index=0
         for u in ${users[@]}; do
            userGroups=($(id -G -n $u))
            if ! [[ ${userGroups[@]} =~ $group ]]; then
               unset users[$index]
               index=$((index + 1))
            fi
         done

      elif [[ -v argOpt[s] || -v argOpt[e] ]]; then
         start=$(date -d "${argOpt['s']}" +"%Y-%m-%d ")
         start+="$(echo "${argOpt['s']}" | awk '{print $3}')"
         start=" -s \"$start\" "

         end=$(date -d "${argOpt['e']}" +"%Y-%m-%d ")
         end+="$(echo "${argOpt['e']}" | awk '{print $3}')"
         end=" -t \"$end\" "

         users=$(eval last $start $end | awk '{if($10 !~ /in/) {print $1}}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d')
      else
         users=$(last | awk '{if($10 !~ /in/) {print $1}}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d')
      fi
   fi

}

function calculateTime() {
   time=$1

   # Calcular tempo em minutos
   if ((${#time} >= 7)); then
      minlogged=$(echo $time | tr '+' ':' | awk -F: '{ print ($1 * 1440) + ($2 * 60) + $3 }')
   else
      minlogged=$(echo $time | awk -F: '{ print ($1 * 60) + $2 }')
   fi
   # Calcular o total
   total=$(($total + $minlogged))

   # Calcular máximo e mínimo
   if ((minlogged < min)); then
      min=$minlogged
   fi

   if ((minlogged > max)); then
      max=$minlogged
   fi
}

function getUserInfo() {
   echo "I may take a while to process, but I'll get there. Please have a little faith!"

   for user in ${users[@]}; do
      if [[ -v argOpt[f] ]]; then
         sessions=$(last -f "${argOpt['f']}" | grep -o $user | wc -l)
         time=$(last -f "${argOpt['f']}" | grep $user | awk '{print $10}' | sed '/in/d' | sed 's/[)(]//g')
      else
         sessions=$(last | grep -o $user | wc -l)
         time=$(last | grep $user | awk '{print $10}' | sed '/in/d' | sed 's/[)(]//g')
      fi

      min=3000000
      max=0
      total=0

      for t in $time; do
         calculateTime "$t"
      done

      userInfo[$user]=$(printf "%-8s %-5s %-6s %-5s %-5s\n" "$user" "$sessions" "$total" "$max" "$min")
   done
   printIt
}

function printIt() {
   if [[ -v argOpt[r] ]]; then
      # ordem decrescente(nome user)
      order="-rn"
   else
      order="-n"
   fi

   if [[ -v argOpt[n] ]]; then
      # ordenar por numero de sessoes
      printf "%s\n" "${userInfo[@]}" | sort -k2,2 ${order}

   elif [[ -v argOpt[t] ]]; then
      # por tempo total
      printf "%s\n" "${userInfo[@]}" | sort -k3,3 ${order}

   elif [[ -v argOpt[a] ]]; then
      # por tempo máximo
      printf "%s\n" "${userInfo[@]}" | sort -k4,4 ${order}

   elif [[ -v argOpt[i] ]]; then
      # por tempo mínimo
      printf "%s\n" "${userInfo[@]}" | sort -k5,5 ${order}

   else
      #ordem crescente (nome user)
      printf "%s\n" "${userInfo[@]}" | sort -k1,1 ${order}
   fi
}

args "$@"
getUsers
getUserInfo
