------------------------------------------------------------
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


Ao chamar o interpretador de Julia, ao usar "JuMP" e "Gurobi", o programa irá verificar se estes pacotes estão instalados. Caso não estejam, irá instalar.

julia> using JuMP, Gurobi
 │ Packages [JuMP, Gurobi] not found, but packages named [JuMP, Gurobi] are available from a registry. 
 │ Install packages?
 │   (@v1.11) pkg> add JuMP Gurobi 
 └ (y/n/o) [y]: 


