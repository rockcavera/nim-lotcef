# Package

version       = "0.1.0"
author        = "rockcavera"
description   = "Baixa os resultados das loterias da Caixa Econômica Federal"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["lotcef"]


# Dependencies

requires "nim >= 1.0.0"

task release, "Construindo uma versão de lançamento...":
  withDir "src":
    exec "nim c -d:release -o:../bin/lotcef lotcef"

task debug, "Construindo uma versão de depuração...":
  withDir "src":
    exec "nim c -o:../bin/lotcef lotcef"
