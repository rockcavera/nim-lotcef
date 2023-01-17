import std/sets

import ./parsers, ./types

proc initSorteio(nome: string, tipo: SorteioTipo, quantidade, menor, maior,
                 iTd: int): SorteioObj =
  ## Procedimento para iniciar um `SorteioObj`.
  ##
  ## Parâmetros
  ## - `nome`: Bola, Coluna, Trevo, Mês da Sorte, Time da Sorte... do tipo de sorteio
  ## - `tipo`: é uma das opções do enumerador `SorteioTipo`: `Inteiro` ou `String`
  ## - `quantidade`: quantidade de bolas, collunas, trevos, mês, time, etc. sorteado
  ## - `menor`: é o menor número sorteado
  ## - `maior`: é o maior número sorteado
  ## - `iTd`: é o índice inicial da tag `td` durante a análise
  result.nome = nome
  result.tipo = tipo
  result.quantidade = quantidade
  result.menor = menor
  result.maior = maior
  result.iTd = iTd

proc initDiaDeSorte(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade Dia
  ## de Sorte.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Dia%20de%20Sorte"
  result.modalidade = DiaDeSorte
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 7, 1, 31, 4),
                     initSorteio("Mês da Sorte", String, 1, -1, -1, 11)]

proc initDuplaSena(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade Dupla
  ## Sena.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Dupla-Sena"
  result.modalidade = DuplaSena
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Sorteio 1 Bola", Inteiro, 6, 1, 50, 3),
                     initSorteio("Sorteio 2 Bola", Inteiro, 6, 1, 50, 21)]

proc initLotofacil(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## Lotofácil.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Lotof%C3%A1cil"
  result.modalidade = Lotofacil
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 15, 1, 25, 3)]

proc initLotomania(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## Lotomania.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Lotomania"
  result.modalidade = Lotomania
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 20, 0, 99, 3)]

proc initMaisMilionaria(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## +Milionária.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=+Milion%C3%A1ria"
  result.modalidade = MaisMilionaria
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 6, 1, 50, 3),
                     initSorteio("Trevo", Inteiro, 2, 1, 6, 9)]

proc initMegaSena(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## Mega-Sena.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Mega-Sena"
  result.modalidade = MegaSena
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 6, 1, 60, 3)]

proc initQuina(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## Quina.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Quina"
  result.modalidade = Quina
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 5, 1, 80, 3)]

proc initSuperSete(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade Super
  ## Sete.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Super%20Sete"
  result.modalidade = SuperSete
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Coluna", Inteiro, 7, 0, 9, 3)]

proc initTimemania(): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` com as configurações para a modalidade
  ## Timemania.
  result.link = "https://servicebus2.caixa.gov.br/portaldeloterias/api/resultados?modalidade=Timemania"
  result.modalidade = Timemania
  result.parserProc = parseGenerico
  result.sorteio = @[initSorteio("Bola", Inteiro, 7, 1, 80, 3),
                     initSorteio("Time do Coração", String, 1, 1, 25, 10)]

proc initProcesso*(m: Modalidades): ProcessoObj =
  ## Inicia um objeto `ProcessoObj` de acordo com a modalidade de `m`.
  case m
  of DiaDeSorte:
    result = initDiaDeSorte()
  of DuplaSena:
    result = initDuplaSena()
  of Lotofacil:
    result = initLotofacil()
  of Lotomania:
    result = initLotomania()
  of MaisMilionaria:
    result = initMaisMilionaria()
  of MegaSena:
    result = initMegaSena()
  of Quina:
    result = initQuina()
  of SuperSete:
    result = initSuperSete()
  of Timemania:
    result = initTimeMania()
  of Desconhecida:
    quit("Erro: `initProcesso()` - não é possível iniciar um processo com a modalidade `Desconhecida`!", 1)

proc initConfiguracoes*(): Configuracoes =
  ## Inicia as configurações padrões.
  result.modalidades = initHashSet[Modalidades](16)
  result.imprimirConcurso = false
  result.cortarZeroEsquerda = false
  result.csv = false
