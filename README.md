# Sistemas Operativos - Trabalho 1

## Estatísticas de utilizadores em bash

O objectivo do trabalho é o desenvolvimento de scripts em bash que permitem recolher algumas estatísticas sobre o modo como os utilizadores estão a usar o sistema computacional. Estas ferramentas permitem visualizar o número de sessões e o tempo total de ligação para uma selecção de utilizadores e um determinado período de tempo. Permitem também comparar os dados obtidos em em períodos distintos.

##  Preparação
Estas instruções vão ajudar a executar os programas desenvolvidos.

### Requisitos
O trabalho desenvolvido teve unicamente como propósito a implementação em ambientes Linux e sistemas operativos baseados em UNIX de modo a executar scripts em bash.  

## Executar

**Executar o script das estatísticas dos utilizadores (userstats.sh)**
```
 ./userstats.sh -g [grupo] -u [nome] -s [data1] -p [data2] -r -n -t -a -i
 
  [grupo] - Grupo de utilizadores
  [nome] - Nome dos utilizadores
  [data1] - Data de início da sessão a partir da qual as sessões devem ser consideradas
  [data2] - Data de início de sessão a partir da qual as sessões não devem ser consideradas
  
  Todas estas opções são opcionais, sendo que o script corre sem nenhuma opção.

```

**Executar o script da comparação das estatísticas dos utilizadores (comparestats.sh)**
```
 ./comparestats.sh -r -n -t -a -i [ficheiro1] [ficheiro2]
 
[ficheiro1] = Ficheiro mais recente para ser comparado
[ficheiro2] = Ficheiro mais antigo para ser comparado

```

## Detalhes
É possível encontrar todos os detalhes, nomeadamente os resultados, no [Relatório do Trabalho](/relatorio/SO_Report.pdf).

## Autores

 - **[Hugo Paiva de Almeida](https://github.com/hugofpaiva) - 93195**
 - **[Carolina Araújo](https://github.com/carolinaaraujo00) - 93248**
 
 ## Nota
Classificação obtida de **17** valores em 20.



