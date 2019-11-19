#!/bin/bash

#path="/var/log/wtmp"
path="last.txt"

#Arrays para a leitura de ficheiro:

file_array=() #Array onde vai ser guardado o conteúdo do ficheiro
users=()      #Array onde vão ser guardados os utilizadores
users_unique=()
group=()            #Array onde vão ser guardados os grupos de utilizadores
session=()          #Array onde vai ser guardado o tempo total de ligação
init_data=()        #Array onde vai ser guardada a data de início da sessão
final_hour=()       #Array onde vai ser guardada a hora de fim da sessão
num_users_unique=() #Array onde vai ser guardado o número de users únicos e os users
init_hour=()        #Array onde vai ser guardado a hora de início de sessão
min_session=()      #Array onde vai ser guardado o tempo total de ligação (minutos)

# Leitura de ficheiro:
# -r: opção passada para o comando read que evita o "backslash escape" de ser interpretado
# IFS=:Opção antes do comando read que previne os espaços de serem cortados
function read_file() {
   while IFS= read -r line; do
      file_array+=("$line")
      #IFS=' ' read -r -a array <<< "$line" #outra maneira de ler
   done <"$path"
   #Estou a colocar os elementos do file_array no array. Faço o split com espaço
   #IFS=' ' read -r -a array <<<"$file_array" #outra maniera de ler
   #echo "${array[0]}"
   #readarray a < $path
   #echo "${a[60]}"

}

#read_file

# Usage - Como se usa o script
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

init_data+=$(last | awk '!/^wtmp/{print $3 "\t" $4 "\t" $5 "\t" $6}')
init_hour+=$(last | awk '!/^wtmp/{print $6}')
final_hour+=$(last | awk '!/^wtmp/{print $8}')
session+=$(last | awk '!/^wtmp/{print substr($9,2,5)}') #### O !/^wtmp/ ignora a linha que começa por wtmp e por consequência, a linha em branco anterior
min_session+=$(echo "${session[@]}" | awk '{print (((substr($1,0,2)*60)+substr($1,4,5)))}')
users+="$(last | awk '!/^wtmp/{print $1}')"                 # o | manda o comando last para o awk e é guarda a info no array users
users_unique+=$(echo "${users[@]}" | tr ' ' '\n' | sort -u) #array apenas com unique users #uniq -c #space (‘ ‘) is replaced by tab (‘\t’), fazemos isto pq o sort compara linhas #-u:only output the first of
#a sequence of lines that compare equal
num_users_unique+=$(
   IFS=$'\n'
   sort <<<"${users[*]}" | uniq -c
)
#echo $(echo "${session[*]}" | awk '{print $2 " " $1}')
#echo ${min_session[@]}
#echo "${session[@]}"
#echo "${users[@]}"
###################### TESTES ##############################
#Ir buscar o count do user do array tem_users que tem a contagem e o nome dos user únicos
#for each in "${temp_users[@]}"
#do
# num_users+=$(echo "$each" | awk '{print $2}')
#done
#ou
#num_users+=$(echo "${temp_users[*]}" | awk '{print $1}')
#print do num_users
#echo "${#num_users[*]}"# vai buscar o length do array por causa do "#"
#echo "${num_users[*]}"
############################################################

#Tratamento de opções
# -z: vai testar se o "$1" é uma string nula ou não. Se for uma string nula, é executado.
#    [ -z "$1" ] )
if [ -z "$1" ]; then #Este if verifica se é passada algum arguemto ou não. Tem de ter espaços a toda a volta do "[" "]"
   #echo "Nenhum argumento ou opção"
   #Print das opções de acordo com o pedido na opção:
   printf "%s %s \n" "$(echo "${num_users_unique[*]}" | awk '{print $2 " " $1}')" #Vai trocar a order do num_users_unique para fazer display corretamente

   exit

else

   while getopts g:u:s:e:f:rntai option; do # As opções são passadas todas a seguir ao getopts. Se tiver ":" quer dizer que aceita argumentos. O "${OPTARG}" são os argumentos
      case "${option}" in
      g)
         if [ ${2:0:1} == "-" ]; then #Verifica se o 1º caracter do 2º argumento é um "-", ou seja, uma opção. Se isto não acontecer, quer dizer que é um argumento e a função corre normal.
            usage
         else
            echo "A opção g foi ativada."
            $(last)

         fi
         ;;
      u)
         echo ${2:0:1}
         if [ ${2:0:1} == "-" ]; then #Verifica se o 1º caracter do 2º argumento é um "-", ou seja, uma opção. Se isto não acontecer, quer dizer que é um argumento e a função corre normal.
            usage
         else

            echo "ok"
            argumento_b="${OPTARG}"
         fi
         ;;
      s)
         if [ ${2:0:1} == "-" ]; then #Verifica se o 1º caracter do 2º argumento é um "-", ou seja, uma opção. Se isto não acontecer, quer dizer que é um argumento e a função corre normal.
            usage
         else
            recebi_c=1
            echo "s"
         fi
         ;;
      e)
         if [ ${2:0:1} == "-" ]; then #Verifica se o 1º caracter do 2º argumento é um "-", ou seja, uma opção. Se isto não acontecer, quer dizer que é um argumento e a função corre normal.
            usage
         else
            echo "e"
            recebi_d=1
         fi
         ;;
      f)
         if [ ${2:0:1} == "-" ]; then #Verifica se o 1º caracter do 2º argumento é um "-", ou seja, uma opção. Se isto não acontecer, quer dizer que é um argumento e a função corre normal.
            usage
         else
            echo "O script vai ler do ficheiro ${OPTARG}"
            init_data+=$(last -f ${OPTARG} | awk '{print $3 "\t" $4 "\t" $5 "\t" $6}')
            users+=($(last -f ${OPTARG} | awk '{print $1}'))              # o | manda o comando last para o awk e é guarda a info no array users
            users_unique+=($(echo "${users[@]}" | tr ' ' '\n' | sort -u)) #array apenas com unique users #uniq -c #space (‘ ‘) is replaced by tab (‘\t’), fazemos isto pq o sort compara linhas #-u:only output the first of
            #a sequence of lines that compare equal
            # print da info para testes
            for i in "${init_data[@]}"; do
               :
               echo "$i"
            done
            exit
         fi
         ;;
      r)
         echo "oko"
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

   if [ $OPTIND -eq 1 ]; then #Este if corre se não houve nenhuma opção mas forem passado argumentos
      echo " "
      echo "Nenhuma opção mas foram passado argumentos"
      echo " "
      usage
   fi

   shift $((OPTIND - 1))

fi

#shift $((OPTIND-1)) Este shitf vai fazer desaparecer dos argumentos $1, $2, ... as opções e argumentos passado ao getopts
#Logo, ao fazer echo "$1" vai-me dar os outros argumentos não utilizados em getopts
#echo "$1"
