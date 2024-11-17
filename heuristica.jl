
#----------------------------------------------------------------
function Heuristica(G::RouteType,MaxTimeSeconds::MyInt)
         

	StartingTimeSeconds = time()
	BestSolutionValue = Inf
	BestSolution = []


	while ((time()-StartingTimeSeconds) < MaxTimeSeconds)

		S, P, D = ConstructInitialSolution(G, div(MaxTimeSeconds, 50))

		LocalBestSolutionValue = LocalSearch(G, S, P, D, div(MaxTimeSeconds, 50))

		if (LocalBestSolutionValue < BestSolutionValue)
			BestSolution = copy(S)
			BestSolutionValue = LocalBestSolutionValue
			println("Solucao global atualizada: ", BestSolutionValue)
		end

	end

	println("Melhor solucao encontrada: ", BestSolutionValue)

	G.BestValue = BestSolutionValue

	for i in 1:2*G.K
		G.BestSol[i] = BestSolution[i]
	end

end
