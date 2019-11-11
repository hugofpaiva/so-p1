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
read_file()

#Tratamento de opções para a ordem de visualização. Vou buscar as opções ao 2º argumento 
function order_sessions(){
    case $2 in

    -r)
        statements ;;
    -n )
        statements ;;
    -t )
        statements ;;
    -a )
        statements ;;
    -i )
        statements ;;

esac

}
#Tratamento de opções. "$1" corresponde ao 1º Argumentos
case $1 in
# -z: vai testar se o "$1" é uma string nula ou não. Se for uma string nula, é executado.
#    [ -z "$1" ] ) 
      )
      if [![ -z "$2" ]] # Se o 2º argumento não for uma string nula
      then
      fi
        statements ;;
    -g )
        statements ;;
    -u )
        statements ;;
    -s )
        statements ;;
    -e )
        statements ;;
    -f )
        #Vou buscar o path para o ficheiro que quero ler ao 2º argumento - "$2"
        path = $2
        read_file() ;;
esac