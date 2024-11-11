#------------------------------------------------------------
# Coloque neste arquivo as rotinas, tipos,...
# usados tanto na parte heurística como exata.
#------------------------------------------------------------


function ConstructInitialSolution(G::RouteType)

    P::Vector{MyInt} =  Vector{MyInt}(undef,G.K) # position of pick i inside the solution vector
    D::Vector{MyInt} =  Vector{MyInt}(undef,G.K) # position of delivery i inside the solution vector
    S::Vector{MyInt} =  Vector{MyInt}(undef,2 * G.K) # Solution vector

    S[1] = 1
    S[2*G.K] = 1 + G.K

    for i in 2:G.K-1
        S[i] = i
        S[i + 1] = i + G.K
        i = i + 1
    end

    P[1] = 1
    D[1] = 2*G.K

    for i in 2:G.K - 1
        P[i] = i
        D[i] = i + 1
    end

    S[1] = 1          
    S[2*G.K] = 1 + G.K 

    return S, P, D
end

function HeuristicCost(G::RouteType, S::Vector{MyInt}, P::Vector{MyInt}, D::Vector{MyInt})
    
    TotalCost = 0
    
    for i in 1:G.K - 1
        TotalCost = TotalCost + G.Dist[S[i],S[i+1]]
        i = i + 1
    end

    for i in 1:G.K
        if (D[i] < P[i])
            TotalCost = Inf
            return TotalCost
        end

        TotalTime = 0

        for j in P[i]:D[i] - 1  
            TotalTime = TotalTime + G.Time[S[j],S[j+1]]
        end

        if (TotalTime > G.Delta[i])
            TotalCost = Inf
            return TotalCost
        end
    end

    TotalCost = TotalCost + G.Dist[S[G.K],S[2*G.K]]

    return TotalCost
end


function LocalSearchStep(G::RouteType, S::Vector{MyInt})

    a = MyRand(2,2*G.K-1)
    b = MyRand(2,2*G.K-1)
    if (a==b)
        continue
    end
    aux=S[a]
    S[a]=S[b]
    S[b]=aux
end


function TabuSearch(G::RouteType, MaxTimeSeconds::MyInt)
    StartingTimeSeconds = time()

    S, P, D = ConstructInitialSolution(G)
    
    # Initialize best solution and its value
    BestSolution = copy(S)
    BestSolutionValue = HeuristicCost(G, S, P, D)
    
    # Initialize tabu list (using a simple array of moves)
    tabuSize = min(20, G.K) # Typical tabu list size
    tabuList = Vector{Tuple{MyInt,MyInt}}()
    
    while ((time()-StartingTimeSeconds) < MaxTimeSeconds)
        
    end
    
    # Restore best solution found
    copyto!(H, BestSolution)
    return BestSolutionValue
end
