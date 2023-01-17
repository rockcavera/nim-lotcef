import std/strformat

proc join*(a: openArray[int], cortarZeroEsquerda: bool, sep: string = ""): string =
  ## Junta todos os elementos de `a` em uma `string` separada por `sep`.
  ## Adiciona zero à esquerda se `cortarZeroEsquerda` for `false`.
  for i, x in a:
    if i > 0:
      add(result, sep) # Separador
    if cortarZeroEsquerda:
      add(result, $x)
    else:
      add(result, fmt"{x:02}")
