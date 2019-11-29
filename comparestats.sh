#!/bin/bash

# Arrays para guardar users e a sua informaçao
users1=()              #Array para os user do 1º ficheiro
users2=()              #Array para os user do 2º ficheiro
declare -A argOpt=()   #Array Associativo onde são guardadas os argumento correspondentes às opções passadas
declare -A userInfo=() #Array Associativo onde é guardada a informação após o tratamento de dados correspondente a cada utilizador     

# Usage do script

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
    repeat=0
    while getopts rntai option; do
        case "${option}" in
        r);;
      n | t | a | i) 
      if [[ $repeat = 1 ]];then
         usage
      else
         repeat=1
      fi   
      ;;

        *)

            usage
            ;;
        esac

        argOpt[$option]="none" 

    done

    if [ $(($OPTIND+1)) -eq $# ]; then
            eval input1=\$$((OPTIND))
            eval input2=\$$((OPTIND + 1))
        else
            usage
        fi

    shift $((OPTIND - 1))

}

# Tratamento e leitura de dados

function getUsers() {
    users1=$(cat $input1 | awk '{print $1}' | sort)
    users2=$(cat $input2 | awk '{print $1}' | sort)
    users=(${users2[@]} ${users1[@]})
    unique_users=$(echo "${users[@]}" tr " " "\n" | sort | uniq -u | tr "\n" " ")
}

function getUserInfo() {
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
