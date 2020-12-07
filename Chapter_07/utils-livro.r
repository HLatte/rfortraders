# Lembrete para salvar a lista de acoes e seus dados
#   library("here")
#   save( "acoes", file = here( "/FTSE/00-lista_ativos.rdata"))


# Para instalar o vers?o em desenvolvimento do pacote:
#   devtools::install_github("joshuaulrich/quantmod")
#   devtools::install_github("braverock/blotter")
#   devtools::install_github("braverock/quantstrat")
#   devtools::install_github("braverock/PerformanceAnalytics")
# Outras formas:
#install.packages('PerformanceAnalytics')
#install.packages('FinancialInstrument')

####
# funcao que imprime caso o verbose seja TRUE ####
####
cat_hh <- function(verbose = TRUE, ...) {
  if (verbose == TRUE) {
    cat(...)
  }
  invisible(verbose)
}



print_hh <- function(verbose = TRUE, ...) {
  if (verbose == TRUE) {
    print(...)
  }
  invisible(verbose)
}




####
# funcao que carrega o(s) package(s) ou instala se necessario ####
####
load_package <- function(verbose, list.of.packages) {
  # Load packages
  for (package.name in list.of.packages) {
    if (verbose == TRUE) {
      cat_hh(verbose, "- carregando o pacote:", package.name, "\n")
      if (!require(package.name, character.only = TRUE)) {
        cat_hh(
          verbose,
          "\n*** nao achado. Entao vou instalar o pacote: '",
          package.name,
          "'\n"
        )
        install.packages(package.name)
        library(package.name, character.only = TRUE)
      }
    } else {
      # modo silencioso
      if (!suppressPackageStartupMessages(require(package.name,
        character.only = TRUE
      ))) {
        install.packages(package.name)
        suppressPackageStartupMessages(library(package.name,
          character.only = TRUE
        ))
      }
    }
  }
}



####
# Funcoes de arquivos ####
####

## funcao que le os dados do arquivo e devolve em xts ##
carrega.xts <- function(nome_arquivo) {
  # checa se o arquivo existe
  if (file.exists(nome_arquivo)) {
    # carrega os dados
    temp <- read.zoo(
      file = nome_arquivo,
      sep = ";",
      header = TRUE
    )
    temp <- as.xts(temp)
  } else {
    # se arquivo nao existe, entao retorna um xts vazio
    temp <- xts()
  }
  # fim
  return(temp)
}



## funcao que salva os dados do arquivo e devolve em xts ##
salva.xts <- function(dados, nome_arquivo) {
  # grava o aquivo
  result <- try(write.zoo(dados, sep = ";", file = nome_arquivo))
  # verifica se a grava??o deu certo
  if (class(result) == "try-error") {
    # fim - deu erro
    return(F)
  } else {
    # fim - deu tudo certo
    return(T)
  }
}



## funcao para gravar a lista de acoes ##
grava_acoes <- function(acoes) {
  lista_ativos <- "00-lista_ativos.rdata"
  Path_FTSE <-
    "FTSE/" # "C:/Users/HL/Documents/Recherches/Dados/FTSE/"
  save(acoes, file = here::here(paste0(Path_FTSE, lista_ativos)))
}
