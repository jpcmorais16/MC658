#------------------------------------------------------------
# Coloque neste arquivo as rotinas, tipos,...
# usados tanto na parte heurística como exata.
#------------------------------------------------------------


function ConstructInitialSolution(G::RouteType)

end


function LocalSearchStep(G::RouteType, H::Vector{MyInt})

    a = MyRand(2,G.K)
    b = MyRand(2,G.K)
    if (a==b)
        continue
    end
    aux=H[a]
    H[a]=H[b]
    H[b]=aux
    ChangedSolutionValue = DummyHeuristicCost(G,H)
    if (ChangedSolutionValue < CurrBestSolutionValue)
        # Solucao melhor. Mantem a troca e atualiza o valor desta solucao.
        println("Solucao heuristica melhorou de ",CurrBestSolutionValue," para ",ChangedSolutionValue,".")
        CurrBestSolutionValue = ChangedSolutionValue
    else
        # Troca nao melhorou. Desfaz a troca.
        aux=H[a]
        H[a]=H[b]
        H[b]=aux
    end
end


function TabuSearch(G::RouteType, MaxTimeSeconds::MyInt, H::Vector{MyInt})
    StartingTimeSeconds = time()
    
    # Initialize best solution and its value
    BestSolution = copy(H)
    BestSolutionValue = DummyHeuristicCost(G, H)
    
    # Initialize tabu list (using a simple array of moves)
    tabuSize = min(20, G.K) # Typical tabu list size
    tabuList = Vector{Tuple{MyInt,MyInt}}()
    
    while ((time()-StartingTimeSeconds) < MaxTimeSeconds)
        # Store current solution value before move
        CurrentValue = DummyHeuristicCost(G, H)
        
        # Perform local search step
        a, b = LocalSearchStep(G, H)
        NewValue = DummyHeuristicCost(G, H)
        
        # If move is not tabu or satisfies aspiration criterion
        if !((a,b) in tabuList) || NewValue < BestSolutionValue
            # Update best solution if improved
            if NewValue < BestSolutionValue
                BestSolution = copy(H)
                BestSolutionValue = NewValue
                println("New best solution found: ", BestSolutionValue)
            end
            
            # Add move to tabu list
            push!(tabuList, (a,b))
            
            # Maintain tabu list size
            if length(tabuList) > tabuSize
                popfirst!(tabuList)
            end
        else
            # Reverse the move if tabu
            aux = H[a]
            H[a] = H[b]
            H[b] = aux
        end
    end
    
    # Restore best solution found
    copyto!(H, BestSolution)
    return BestSolutionValue
end
