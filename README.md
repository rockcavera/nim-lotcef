# lotcef
Programa de linha de comandos para baixar os resultados das loterias da Caixa Econômica Federal (CEF). Todos os dados são retirados do site da CEF.

Modalidades implementadas:
- [x] +Milionária
- [x] Dia de Sorte
- [x] Dupla Sena
- [x] Lotofácil
- [x] Lotomania
- [x] Mega-Sena
- [x] Quina
- [x] Super Sete
- [x] Timemania
- [ ] Federal
- [ ] Loteca
## Instalação
### Binários Pré-Construído
Binários pré-construídos para Windows 64 (amd64) e 32 (i386) estão disponíveis em [releases](/releases/latest).

Observação: o download dos binários pré-construídos vêm com duas dlls, libcrypto-1_1.dll e libssl-1_1.dll no i386, e libcrypto-1_1-x64.dll e libssl-1_1-x64.dll no amd64. Essas dlls são essenciais para a execução do programa e são criadas pela construção dinâmica do [OpenSSL](https://www.openssl.org/).
### Construção a partir do Código Fonte
Primeiramente será necessário instalar o compilador [Nim](https://nim-lang.org/install.html). Aconselha-se a colocar o Nim na variável de ambiente PATH do seu sistema operacional.

Após, baixe como deseja baixar o código fonte:
1. Pode ser na página de [lançamentos](/releases/latest) (pelo próprio navegador, wget, curl, etc.) e proceder a descompactação do arquivo .zip ou .tar.gz; ou
2. Utilizar algum programa que interaja com repositórios gits, como o próprio [git](https://git-scm.com/), e clonar o repositório com: `git clone https://github.com/rockcavera/nim-lotcef.git`.

Agora, com o código fonte, acesse a pasta onde está o `lotcef.nimble` e digite: `nimble release`. Esse comando irá construir uma versão de lançamento do executável `lotcef`, na pasta `/bin/`.
## Modo de uso
Por ser um programa de linha de comandos, você necessita acessar o terminal do seu Sistema Operacional. No Windows você pode usar o powershell ou cmd (prompt de comandos). Caso não saiba como fazer, pesquise no [Google](https://www.google.com/).

A melhor ajuda pode ser acessada digitando no terminal: `lotcef -h`. Será impresso isso:
```
Modo de uso:

  lotcef [opções] <modalidade> [modalidade2] ... [modalidadeN]

Opções:
  -c --imprimirConcurso    Imprime o número dos concursos no arquivo de saída
  -h --ajuda|help          Exibe esse conteúdo
  -u --utf8bom             Marca o arquivo de saída como UTF-8
  -z --cortarZeroEsquerda  Corta os zeros a esquerda (Sempre ativo com --csv)

  --csv                    Cria o arquivo de saída como CSV

Modalidades:
  Nome          Também Aceita

  +Milionária   +Milionaria, + Milionária, + Milionaria, MaisMilionária,
                MaisMilionaria, Mais Milionária, Mais Milionaria, Milionária,
                Milionaria
  Dia de Sorte  Dia-de-Sorte, DiadeSorte
  Dupla Sena    DuplaSena, Dupla-Sena, Dupla
  Lotofácil     Lotofacil, Loto Fácil, Loto Facil
  Lotomania     Loto Mania
  Mega-Sena     MegaSena, Mega, Mega Sena
  Quina
  Super Sete    Super-Sete, SuperSete, Super 7, Super-7, Super7
  Timemania     Time Mania

Observações:
  1) Parâmetros entre <> são necessários. Parâmetros entre [] são opcionais.
  2) Modalidades como Dia de Sorte, Super Sete e Dupla Sena devem ser colocadas
     entre aspas duplas "". Exemplos "Dia de Sorte", "Super Sete", "Dupla Sena".
  3) As modalidades podem ser escritas tanto em minúsculo quanto em maiúsculo.
     Isso não importa. O programa transforma tudo para minúsculo antes de
     analisar.
  4) O nome do arquivo de saída gerado é: "MODALIDADE ANO-MÊS-DIA
     HORA-MINUTO-SEGUNDO.txt". Porém, se for passada a opção --csv, o nome do
     arquivo será "MODALIDADE ANO-MÊS-DIA HORA-MINUTO-SEGUNDO.csv".
  4) Todos os dados são retirados do site da Caixa Econômica Federal.
  5) É preciso ter conexão com a internet.
```
Para baixar todos os resultados em formato CSV com o concurso digite:
```
lotcef --csv -c +Milionária "Dia de Sorte" "Dupla Sena" Lotofácil Lotomania Mega-Sena Quina "Super Sete" Timemania
```
