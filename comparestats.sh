#!/bin/bash

# Arrays para guardar users e a sua informaçao
users1=() #Array para os user do input1
users2=() #Array para os user do input2
file_array=()
declare -A argOpt=()      #Array associativo onde são guardadas os argumento correspondentes às opções passadas
declare -A userInfo=()    #Array associativo onde são guardados os dados para serem imprimidos de cada user
options_control=(n t a i) #Array com as opções que não podem ser repetidas
input=() #Array com os inputs

# Verificar que não há mais que dois ficheiros
#input=$(echo "$@" | awk '$1 ~ /^⁻/ ')
#echo "${input[@]}"
input1=$1
input2=$2


# Usage das opções - Como se usa o script
function usage() {
    echo "Usage: $0  -r -n -t -a -i [ficheiro1] [ficheiro2]"
    echo ""
    echo "[ficheiro1] = Ficheiro mais recente para ser comparado"
    echo "[ficheiro2] = Ficheiro mais antigo para ser comparado"
    echo ""
    exit
}

# Tratamento de opções
function args() {

    while getopts g:u:s:e:f:rntai option; do
        case "${option}" in
        r | n | t | a | i) ;;
        *)
            usage
            ;;
        esac

        #Controlo das opções que não podem ser repetidas
        for i in "${options_control[@]}"; do #Vou percorrer o array das opções que não podem ser repetidas
            if [[ -v argOpt[$i] ]]; then #Verifico se já existe umas dessas opções
                usage
            fi
        done

            argOpt[$option]="none" #Guarda no array associativo com a key correspondente à opção, o value do argumento
        

    done

    shift $((OPTIND - 1))
    
    if [ -z "$1" ]; then #Se não for passado nada
usage
fi

}

# Tratamento e leitura de dados

function getUsers() {
    users1=$(cat $input1 | awk '{print $1}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d')
    users2=$(cat $input2 | awk '{print $1}' | sort | uniq | sed '/reboot/d' | sed '/wtmp/d')
    users=(${users2[@]} ${users1[@]})
    unique_users=($(echo "${users[@]}" | tr ' ' '\n' | sort | uniq -u | tr '\n' ' '))
}

function getUserInfo() {
    echo "I may take a while to process, but I'll get there. Please have a little faith!"
    for user1 in ${users1[@]}; do
        sessions1=$(cat $input1 | grep $user1 | awk '{print $2}')
        total1=$(cat $input1 | grep $user1 | awk '{print $3}')
        max1=$(cat $input1 | grep $user1 | awk '{print $4}')
        min1=$(cat $input1 | grep $user1 | awk '{print $5}')
        for user2 in ${users2[@]}; do
            sessions2=$(cat $input2 | grep $user2 | awk '{print $2}')
            total2=$(cat $input2 | grep $user2 | awk '{print $3}')
            max2=$(cat $input2 | grep $user2 | awk '{print $4}')
            min2=$(cat $input2 | grep $user2 | awk '{print $5}')
            if [ "$user2" = "$user1" ]; then
                sessions=$(($sessions1 - $sessions2))
                total=$(($total1 - $total2))
                max=$(($max1 - $max2))
                min=$(($min1 - $min2))
                userInfo[$user2]=$(printf "%-8s %-5s %-6s %-5s %-5s\n" "$user2" "$sessions" "$total" "$max" "$min")
            else
                for unique in ${unique_users[@]}; do
                    if [ "$unique" = "$user1" ]; then
                        userInfo[$user1]=$(printf "%-8s %-5s %-6s %-5s %-5s\n" "$user1" "$sessions1" "$total1" "$max1" "$min1")
                    elif [ "$unique" = "$user2" ]; then
                    userInfo[$user2]=$(printf "%-8s %-5s %-6s %-5s %-5s\n" "$user2" "$sessions2" "$total2" "$max2" "$min2")
                    fi
                done
            fi
        done

    done

    printIt
}

function printIt() {
    if [[ -v argOpt[r] ]]; then
        # ordem decrescente(nome user)
        order="-r"
    else
        order=""
    fi

    if [[ -v argOpt[n] ]]; then
        # ordenar por numero de sessoes
        printf "%s\n" "${userInfo[@]}" | sort -k1,1n ${order}

    elif [[ -v argOpt[t] ]]; then
        # por tempo total
        printf "%s\n" "${userInfo[@]}" | sort -k2,2n ${order}

    elif [[ -v argOpt[a] ]]; then
        # por tempo máximo
        printf "%s\n" "${userInfo[@]}" | sort -k3,3n ${order}

    elif [[ -v argOpt[i] ]]; then
        # por tempo mínimo
        printf "%s\n" "${userInfo[@]}" | sort -k5,5n ${order}

    else
        #ordem crescente (nome user)
        printf "%s\n" "${userInfo[@]}" | sort -k1,1n ${order}
    fi
}

args "$@"
getUsers
getUserInfo
