import std/[algorithm, htmlparser, parseutils, streams, strformat, strutils,
            xmltree] # Importações stdlib

import ./types, ./utils # Importações internas

proc parseGenerico*(cfg: Configuracoes, p: ProcessoObj, html: XmlNode) =
  ## Analisador genérico para as modalidades lotéricas da CEF.
  ##
  ## Aqui é analisado todo o html em busca dos dados.
  ##
  ## - `cfg` traz as configurações gerais do programa, que podem ser alteradas com
  ##   opções no chamamento pela linha de comando.
  ## - `p` traz os dados necessários para processar a análise de acordo com a
  ##   modalidade. O próprio `parseGenerico` e chamado a partir deste objeto.
  ## - `html` é o conteúdo baixado que será analisado.
  var
    ultimoConcurso = low(int) # Registro do último concurso analisado
    sep = " " # Separador
    x = 0 # Contador de tags `tbody`

  if cfg.csv:
    sep = ";" # Altera o separador para ";" quando --csv

    # Impressão do cabeçalho do arquivo CSV
    if cfg.imprimirConcurso:
      write(p.fs, "Concurso;")

    for s in p.sorteio:
      for i in 1 .. s.quantidade:
        write(p.fs, fmt"{s.nome} {i}{sep}")

    setPosition(p.fs, getPosition(p.fs) - len(sep)) # Voltar antes do último separador
    write(p.fs, "\p") # Sobrescrever último separador com uma nova linha da plataforma

  for tbody in findAll(html, "tbody"): # Procura por todas as tags `tbody`
    x = x +% 1

    if (x and 1) != 1: continue # As tags `tbody` pares não importam.

    var tbody = tbody

    if p.modalidade == DuplaSena: # /!\ Especificidade da tabela de resultados da Dupla Sena
      var strTbody = $tbody # As cidades dos ganhadores atrapalham a análise

      let
        iTable = find(strTbody, "<table>") # Procurar onde começa "<table>"
        fTable = find(strTbody, "</table>", iTable + 6) # Procurar onde termina

      if (iTable != -1) and (fTable != -1): # Se achou...
        when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0): # Para manter compatibilidade entre versões do compilador
          delete(strTbody, iTable..(fTable + 7)) # Então deleta tudo que está entre elas
        else:
          delete(strTbody, iTable, fTable + 7)

      tbody = parseHtml(strTbody) # Voltando o tbody sem `<table>[...]</table>`

    for tr in findAll(tbody, "tr"): # Procura por todas as tags `tr`
      var
        y = 0 # Contador de tags `td`
        concurso = low(int) # Onde vai salvar o concurso analisado
        nums = newSeq[IntOrString](len(p.sorteio)) # Onde vão ser salvas as bolas/trevos/mês/time sorteados
        quantidadeNums = 0 # Quantidade de bolas/trevos/mês/time sorteados

      for i, s in p.sorteio:
        quantidadeNums += s.quantidade

        case s.tipo
        of Inteiro:
          nums[i].i = newSeqOfCap[int](s.quantidade)
        of String:
          nums[i].s = newSeqOfCap[string](s.quantidade)

      for td in findAll(tr, "td"): # Procura por todas as tags `td` - Aqui que mora o que queremos =D
        y = y +% 1

        var parsed: int # Variável que vamos guarda os inteiros analisados

        if y == 1: # Número do concurso
          if parseInt(innerText(td), concurso) == 0:
            raise newException(ValueError, fmt"Erro: não foi possível analisar um inteiro para o concurso: '{innerText(td)}'")
        else:
          for i, s in p.sorteio:
            if (y >= s.iTd) and (y < (s.iTd + s.quantidade)): # Verifica se é algum índice que nos interessa
              quantidadeNums = quantidadeNums -% 1 # Diminui `quantidadeNums` para controlar a análise e capturas

              case s.tipo
              of Inteiro:
                if parseInt(innerText(td), parsed) > 0: # Analisa para um inteiro o conteúdo texto de dentro da tag `td` atual
                  if (parsed >= s.menor) and (parsed <= s.maior): # Verifica se o número está dentro do limite da modalidade
                    add(nums[i].i, parsed)
                  else:
                    if (p.modalidade == Lotomania) and (parsed == 100): # /!\ Exceção Lotomania - alguns concursos estão como 100, mas são 0
                      add(nums[i].i, 0)
                    else:
                      raise newException(ValueError, fmt"Erro: {s.nome} não está entre {s.menor} e {s.maior}: '{parsed}'")
                else:
                  raise newException(ValueError, fmt"Erro: Não foi possível analisar um inteiro para a {s.nome}: '{innerText(td)}'")
              of String:
                add(nums[i].s, innerText(td))

        if quantidadeNums <= 0: # Já capturou tudo que deveria capturar =D
          break # Sai do for das tags `td` para o for das tags `tr`

      if (concurso != low(int)) and (quantidadeNums <= 0): # Verifica se capturou tudo que deveria capturar
        if ultimoConcurso != low(int): # Verificar concursos faltando entre concursos
          if (concurso - 1) != ultimoConcurso:
            echo fmt"    Concursos faltantes:"

            for c in (ultimoConcurso + 1) ..< concurso: # Imprimindo os concursos faltantes no `stdout`
              echo fmt"      {c}"

        ultimoConcurso = concurso # Define o último concurso com o concurso capturado agora

        # Impressão para o arquivo de saída
        if cfg.imprimirConcurso: # Se a opção -c ou --imprimirconcurso for passada
          if cfg.csv: # Se a opção --csv for passada
            write(p.fs, fmt"{concurso}{sep}")
          else:
            write(p.fs, fmt"{concurso:05}{sep}")

        for i, s in p.sorteio: # Imprimindo bolas, colunas, times, trevos...
          case s.tipo
          of Inteiro:
            if p.modalidade != SuperSete: # /!\ Super Sete são colunas, não se deve ordenar
              sort(nums[i].i) # Colocando números sorteados em ordem crescente

            write(p.fs, join(nums[i].i, cfg.cortarZeroEsquerda, sep), sep)
          of String:
            write(p.fs, join(nums[i].s, sep), sep)

        setPosition(p.fs, getPosition(p.fs) - len(sep)) # Voltar antes do último separador
        write(p.fs, "\p") # Sobrescrever último separador com uma nova linha da plataforma

        break # Sai do for das tags `tr` para o for das tags `tbody`
      else:
        raise newException(ValueError, fmt"Erro: não foi possível capturar todos os dados para o concurso!")
