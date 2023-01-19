import std/[sets, streams, xmltree] # Importações stdlib

type
  Modalidades* = enum
    ## Enumerador com todas as modalidades
    Desconhecida = "Desconhecida"
    MaisMilionaria = "+Milionária"
    MegaSena = "Mega-Sena"
    Lotofacil = "Lotofácil"
    Quina = "Quina"
    Lotomania = "Lotomania"
    Timemania = "Timemania"
    DuplaSena = "Dupla Sena"
    DiaDeSorte = "Dia de Sorte"
    SuperSete = "Super Sete"

  IntOrString* = object
    ## Objeto para poder termos inteiros e strings em um sorteio. Necessário
    ## para o `parserGenerico`.
    i*: seq[int]
    s*: seq[string]

  SorteioTipo* = enum
    ## Enumerador para orientar o `parseGenerico` que tipo de dados o sorteio
    ## usa e salvar no campo correto do objeto `IntOrString`.
    Inteiro ## Para números inteiros, sem ser decimais
    String ## Para cadeia de caracteres (palavras)

  SorteioObj* = object
    ## Objeto para armazenar as especificações do sorteio
    nome*: string ## Bola, Coluna, Trevo, Mês da Sorte, Time da Sorte...
    tipo*: SorteioTipo
    quantidade*: int ## Quantidade sorteada. Para Mega-Sena é 6.
    menor*: int ## Menor sorteada. Para Mega-Sena é 1.
    maior*: int ## Maior sorteada. Para Mega-Sena é 60.
    iTd*: int ## Número da tag td onde inicia o sorteio

  ProcessoObj* = object
    ## Objeto para armazenar dados necessários para o processamento da
    ## modalidade
    fs*: FileStream
    parserProc*: ParserProc ## Procedimento usado para analisar o html
    link*: string ## Link para baixar os resultados da modalidade
    modalidade*: Modalidades
    sorteio*: seq[SorteioObj]

  ParserProc* = proc (cfg: Configuracoes, p: ProcessoObj, html: XmlNode)
    ## Qualquer analisador de resultado deve ter esse cabeçalho em sua
    ## declaração. Veja o procedimento `parsers.parseGenerico`.

  Configuracoes* = object
    ## Objeto com as configurações do programa
    modalidades*: HashSet[Modalidades] ## Modalidades que serão baixadas os resultados
    imprimirConcurso*: bool ## Se será impresso no arquivo de saída o concurso
    cortarZeroEsquerda*: bool ## Se será cortado os zeros à esquerda
    csv*: bool ## Se o arquivo de saída será um arquivo CSV
    utf8bom*: bool ## Se o arquivo de saída será marcado como UTF-8
