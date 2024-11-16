#------------------------------------------------------------
# Coloque neste arquivo as rotinas, tipos,...
# usados tanto na parte heurística como exata.
#------------------------------------------------------------

using Random

function ConstructInitialSolution(G::RouteType)

    P::Vector{MyInt} =  Vector{MyInt}(undef,G.K) # position of pick i inside the solution vector
    D::Vector{MyInt} =  Vector{MyInt}(undef,G.K) # position of delivery i inside the solution vector
    S::Vector{MyInt} =  Vector{MyInt}(undef,2 * G.K) # Solution vector

    S[1] = 1
    S[2*G.K] = 1 + G.K

    # Initialize random seed based on current time
    Random.seed!(Int(time_ns()))
    pickups = shuffle(collect(2:G.K))
    
    # Place pickups and their corresponding deliveries
    j = 2
    for i in 1:length(pickups)
        current_pickup = pickups[i]
        S[j] = current_pickup
        S[j + 1] = current_pickup + G.K
        j = j + 2
    end
    P[1] = 1
    D[1] = 2*G.K

    for i in 2:2:2*G.K - 1
        P[S[i]] = i
        D[S[i]] = i + 1
    end

    S[1] = 1          
    S[2*G.K] = 1 + G.K 

    return S, P, D
end

function buildTree!(tree::Vector{Int}, array::Vector{Int}, times::Array{MyInt,2}, node::Int, s::Int, e::Int)
    if s == e
        tree[node] = times[array[s], array[s + 1]]
    else
        mid = div(s + e, 2)
        left = 2 * node
        right = 2 * node + 1
        buildTree!(tree, array, times, left, s, mid)
        buildTree!(tree, array, times, right, mid + 1, e)
        tree[node] = tree[left] + tree[right] 
    end
end

function queryTree(tree::Vector{Int}, S::Vector{MyInt}, i::Int, j::Int, s, e, node=1)

    if i > e || j < s
        return 0
    end

    if i <= s && e <= j
        return tree[node]
    end

    mid = div(s + e, 2)
    left_sum = queryTree(tree, S, i, j, s, mid, 2 * node)
    right_sum = queryTree(tree, S, i, j, mid + 1, e, 2 * node + 1)
    return left_sum + right_sum
end

function BuildTimeSegmentTree(G::RouteType, S::Vector{MyInt})
    tree = Vector{Int}(undef, 8 * G.K)
    buildTree!(tree, S, G.Time, 1, 1, 2 * G.K - 1)
    return tree
end

function HeuristicCost(G::RouteType, S::Vector{MyInt}, P::Vector{MyInt}, D::Vector{MyInt})
    
    TotalCost = 0
    
    for i in 1:G.K - 1
        TotalCost = TotalCost + G.Dist[S[i],S[i+1]]
        i = i + 1
    end

    # Seg tree pra achar o somatório de G.Time[S[j],S[j+1]] para j de P[i] até D[i] - 1

    tree = BuildTimeSegmentTree(G, S)


    for i in 1:G.K
        if (D[i] < P[i])
            TotalCost = Inf
            return TotalCost
        end

        TotalTime = queryTree(tree, S, P[i], D[i] - 1, 1, 2 * G.K - 1)

        if (TotalTime > G.Delta[i])
            TotalCost = Inf
            return TotalCost
        end
    end

    TotalCost = TotalCost + G.Dist[S[G.K],S[2*G.K]]

    return TotalCost
end


function LocalSearch(G::RouteType, S::Vector{MyInt}, P::Vector{MyInt}, D::Vector{MyInt}, MaxTimeSeconds::MyInt)
    StartingTimeSeconds = time()
    CurrBestSolutionValue = HeuristicCost(G, S, P, D)
    println("Iniciado")
    trocas = 0

    while (((time()-StartingTimeSeconds))<MaxTimeSeconds/50)
        trocas = trocas + 1
        a = MyRand(2,2 * G.K - 1)
        b = MyRand(2,2 * G.K - 1)

        if (a==b)
            continue
        end

        # P[i] = x; S[x] = i
        # D[i] = y; S[y] = i + G.K

        a_pick = true
        b_pick = true

        if (S[a] <= G.K)
            P[S[a]] = b
        else
            D[S[a] - G.K] = b
            a_pick = false
        end

        if (S[b] <= G.K)
            P[S[b]] = a
        else
            D[S[b] - G.K] = a
            b_pick = false
        end

        aux=S[a]
        S[a]=S[b]
        S[b]=aux


        ChangedSolutionValue = HeuristicCost(G, S, P, D)


        if (ChangedSolutionValue < CurrBestSolutionValue)
           # Solucao melhor. Mantem a troca e atualiza o valor desta solucao.
          println("Solucao heuristica local melhorou de ",CurrBestSolutionValue," para ",ChangedSolutionValue,".")
          println("Trocas: ", trocas)
          trocas = 0
           CurrBestSolutionValue = ChangedSolutionValue
        else
           # Troca nao melhorou. Desfaz a troca.
            aux = S[a]
            S[a] = S[b]
            S[b] = aux
            
            if(a_pick)
                P[S[a]] = a
            else
                D[S[a] - G.K] = a
            end

            if(b_pick)
                P[S[b]] = b
            else
                D[S[b] - G.K] = b
            end 
        end
    end


    return CurrBestSolutionValue
end


