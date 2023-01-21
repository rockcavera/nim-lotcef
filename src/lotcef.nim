import std/[json, htmlparser, httpclient, net, parseopt, sets, streams,
            strformat, strutils, times, unicode] # Importações do stdlib

import ./lotcef/[initializers, types] # Importações internas

const ajuda = """Modo de uso:

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
  Federal       Loteria Federal
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

Programa feito por rockcavera - rockcavera@gmail.com"""

proc parseArgModalidade(m: string): Modalidades =
  ## Analisa o argumento `m`, modalidade, para verificar se corresponde com
  ## alguma configurada e retorna um enumerador de `Modalidades`. Caso não
  ## corresponda, o programa será encerrado com um erro.
  case toLower(m)
  of "dia de sorte", "dia-de-sorte", "diadesorte":
    result = DiaDeSorte
  of "dupla sena", "duplasena", "dupla-sena", "dupla":
    result = DuplaSena
  of "federal", "loteria federal":
    result = Federal
  of "lotofácil", "lotofacil", "loto fácil", "loto facil":
    result = Lotofacil
  of "lotomania", "loto mania":
    result = Lotomania
  of "+milionária", "+milionaria", "+ milionária", "+ milionaria",
     "maismilionária", "maismilionaria", "mais milionária", "mais milionaria",
     "milionária", "milionaria":
    result = MaisMilionaria
  of "mega-sena", "megasena", "mega", "mega sena":
    result = MegaSena
  of "quina":
    result = Quina
  of "super sete", "super-sete", "supersete", "super 7", "super-7", "super7":
    result = SuperSete
  of "timemania", "time mania":
    result = Timemania
  else:
    quit(fmt"Erro: modalidade '{m}' desconhecida!", 1)

proc parseArgs*(cfg: var Configuracoes) =
  ## Faz a análise dos argumentos enviados pela linha de comandos e altera as
  ## configurações do programa em `cfg`
  var p = initOptParser()

  while true:
    p.next()

    case p.kind
    of cmdEnd: # Não tem mais argumentos
      break
    of cmdShortOption: # Opções curtas
      case p.key
      of "c": # -c
        cfg.imprimirConcurso = true
      of "h": # -h
        quit(ajuda, 0)
      of "u": # -u
        cfg.utf8bom = true
      of "z": # -z
        cfg.cortarZeroEsquerda = true
      else:
        quit(fmt"Erro: opção '{p.key}' desconhecida!", 1)
    of cmdLongOption: # Opções longas
      case toLower(p.key)
      of "imprimirconcurso": # --imprimirconcurso
        cfg.imprimirConcurso = true
      of "cortarzeroaesquerda", "cortarzeroesquerda": # --cortarzeroesquerda|cortarzeroaesquerda
        cfg.cortarZeroEsquerda = true
      of "csv": # --csv
        cfg.csv = true
      of "utf8bom": # --utf8bom
        cfg.utf8bom = true
      of "ajuda", "help": # --ajuda|help
        quit(ajuda, 0)
      else:
        quit(fmt"Erro: opção '{p.key}' desconhecida!", 1)
    of cmdArgument: # Modalidades
      incl(cfg.modalidades, parseArgModalidade(p.key))

proc processar(cfg: Configuracoes, m: Modalidades) =
  ## Processa a modalidade `m` usando as configurações em `cfg`.
  ##
  ## É aqui que será feito o download, análise e escrita do arquivo de saída com os resultados.
  var p = initProcesso(m)

  echo fmt"Processando {m}...{'\n'}  Iniciando download dos resultados em '{p.link}'"

  # Download
  var client = newHttpClient(sslContext = newContext(verifyMode = CVerifyNone))

  let content = getContent(client, p.link)

  close(client)

  let
    js = parseJson(content) # Analisa o json baixado
    html = parseHtml(replace(getStr(js["html"]), "\0", "")) # Analisa o html dentro do json.
                      # Quando o json possui caracteres nulos (\u0000) dará bug no htmlparser

  # Definindo nome do arquivo de saída
  var nomeArquivo = $p.modalidade

  add(nomeArquivo, format(now(), " yyyy-MM-dd HH-mm-ss"))

  if cfg.csv:
    add(nomeArquivo, ".csv")
  else:
    add(nomeArquivo, ".txt")

  p.fs = newFileStream(nomeArquivo, fmWrite) # Criando o arquivo de saída

  if isNil(p.fs):
    quit(fmt"Não foi possível criar o arquivo '{nomeArquivo}'", 1)

  if cfg.utf8bom: # Marcará o arquivo de saída como UTF-8 se foi passada essa opção
    write(p.fs, "\239\187\191") # https://pt.wikipedia.org/wiki/Marca_de_ordem_de_byte

  echo "  Analisando..."

  p.parserProc(cfg, p, html) # Chama o procedimento para analisar o conteúdo baixado com os resultados

  echo fmt"  Resultados em '{nomeArquivo}'{'\n'}"

  close(p.fs) # Fecha o arquivo de saída

proc main() =
  ## Procedimento principal/inicial.
  var cfg = initConfiguracoes() # Iniciando a configuração padrão

  parseArgs(cfg) # Analisar os argumentos passados na linha de comando

  if cfg.csv:
    cfg.cortarZeroEsquerda = true # Sempre que a opção --csv for passada cortarZeroEsquerda será verdadeiro

  if len(cfg.modalidades) > 0: # Se houver modalidades elas serão processadas
    for m in cfg.modalidades:
      processar(cfg, m)
  else:
    quit("Erro: sem modalidades!", 1) # Quando não há modalidades o programa encerra com erro

  write(stdout, "Pressione ENTER para terminar. . .")
  discard readChar(stdin)

main()
