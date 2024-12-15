#------------------------------------------------------------
# Exemplo de execucao:
#
# julia routes.jl --ra 999999 --time 5 --npairs 10 --seed 123 --distfactor 0.5 --timefactor 2
#
# ra: seu numero de RA
# time: tempo maximo que seu programa pode executar
# npairs: numero de pares pickup-delivery (o grafo vai ter 2*npairs no's)
# seed: semente para iniciar a geracao de numeros aleatorios
# 	num mesmo programa, para testar com instancias diferentes, basta
#	usar outro numero aleatorio.
# distfactor: para gerar o numero aleatorio, a entrada usa a distancia euclidiana
# 	e acrescenta mais um fator percentual aleatorio dentro deste fator.
# timefactor: a ideia eh parecida com o distfactor, mas eh para ser algo maior
# 	pois vai ser quantas vezes mais vai ser o limite de tempo. Se deixar proximo
#	de zero, vai basicamente colocar o delivery[i] apo's o pickup[i].
#
#--------------------------------------------------------
#        Nao mude o conteudo deste arquivo
#--------------------------------------------------------
using ArgParse
using Base
using Random
using Plots
#--------------------------------------------------------
# Nao mude o conteudo do arquivo mc658_include.jl
include("mc658_include.jl")
#--------------------------------------------------------


#--------------------------------------------------------
# Pode mudar o conteudo dos arquivos: geral.jl, heuristica.jl, exato.jl

include("geral.jl")	    # <<< vai conter rotinas,tipos,... comuns
include("heuristica.jl")    # <<< vai conter o codigo da sua heuristica
include("exato.jl")	    # <<< vai conter o codigo do algoritmo exato

#------------------------------------------------------------
function main()
    (RA,npairs,maxtime,distfactor,timefactor,seednumber) = getparameters()
    #println("npairs = ",npairs)
    #println("distfactor = ",distfactor)
    #println("timefactor = ",timefactor)
    #println("seed = ",seednumber)
    #println("maxtime = ",maxtime)
    
    # Gera uma instancia com os parametros dados
    G=RouteType(npairs,seednumber,distfactor,timefactor)
    # Imprime a instancia gerada
    PrintInstance(G)
    
    #DummyHeuristic(G,maxtime)
    Exato(G,maxtime)
    
    SolutionCost = GetBestSolCost(G)
    println(RA,",",npairs,",",seednumber,",",distfactor,",",timefactor,",",maxtime,",",SolutionCost)
    SaveBestRoutePDF(G,"solution.pdf")
end

#------------------------------------------------------------
# Exemplo de execucao:
# julia routes.jl --ra 999999 --time 5 --npairs 10 --seed 123 --distfactor 0.5 --timefactor 2

main()
