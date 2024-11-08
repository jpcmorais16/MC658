
#----------------------------------------------------------------
function Heuristica(G::RouteType,MaxTimeSeconds::MyInt)
         
	# Denote por D[i] o Delivery de i, e P[i] o Pick de i.
	 # A solucao desta heuristica sempre coloca o "D[i]" logo depois do "P[i]",
	 # por isso eh sempre viavel e neste caso, eh suficiente ter so' um vetor contendo a
	 # sequencia de vertices em {2,3,...,K}.
	 # Lembre que neste problema, o P[1] deve ser o primeiro no' e o D[1] o ultimo no'.
	 # Dada uma sequencia de vertices em {2,3,...,K}, esta heuristica fica
	 # sorteando duas posicoes distintas nesta sequencia, digamos "i" e "j"
	 # e troca eles de posicao. Se o valor desta solucao melhorar, aceita. Caso contrario, nao
	 # efetiva essa operacao e tenta uma proxima troca.

    StartingTimeSeconds = time()
    
    # # H guarda a sequencia heuristica
    # H::Vector{MyInt} =  Vector{MyInt}(undef,G.K)

    # # Comeca com uma solucao dada por
    # #           P[1]->P[2]->D[2]->P[3]->D[3]->...->P[K]->D[K]->D[1]
    # for i in 1:G.K
    #     H[i] = i
    # end

    H::Vector{MyInt} = ConstructInitialSolution(G)

    CurrBestSolutionValue = DummyHeuristicCost(G,H)

    TabuSearch(G, MaxTimeSeconds, H)

    # Itera enquanto tiver tempo
    
	if (CurrBestSolutionValue < G.BestValue)
	   #println("Solucao heuristica melhorou de ",G.BestValue," para ",CurrBestSolutionValue,".")
	   G.BestValue = CurrBestSolutionValue
	   G.BestSol[1] = 1 # first node
	   for i in 1:G.K-1
	       G.BestSol[2*i] = H[i+1]
	       G.BestSol[2*i+1] = H[i+1]+G.K
	   end
	   G.BestSol[2*G.K] = 1+G.K # last node is the target node
	end
end
