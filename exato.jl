using GLPK
using JuMP


function build_pdp_model(G::RouteType,MaxTimeSeconds::MyInt)

    d, t, time_limits = G.Dist, G.Time, G.Delta

    model = Model(GLPK.Optimizer)
    set_optimizer_attribute(model, "msg_lev", GLPK.GLP_MSG_ALL)
    set_optimizer_attribute(model, "tm_lim", MaxTimeSeconds)

    max_t = maximum(t)
    time_limits = time_limits / max_t
    t = t / max_t
    

    @variable(model, x[1:2*G.K, 1:2*G.K], Bin)  
    @variable(model, T[1:2*G.K] >= 0)


    @objective(model, Min, sum(d[i, j] * x[i, j] for i in 1:2*G.K, j in 1:2*G.K))
    

    @constraint(model, [i in 1:2*G.K; i != G.K+1], sum(x[i, j] for j in 1:2*G.K if i != j) == 1)
    @constraint(model, [j in 2:2*G.K], sum(x[i, j] for i in 1:2*G.K if i != j) == 1)
    
    @constraint(model, [i in 1:2*G.K], x[i, i] == 0)
    
    @constraint(model, [i in 1:G.K], T[G.K+i] - T[i] <= time_limits[i])
    @constraint(model, T[1] == 0)
    
    @constraint(model, [i in 1:2*G.K, j in 1:2*G.K; i != j && i != G.K+1],
        T[i] + t[i, j] <= T[j] + (1 - x[i, j]) * sum(t)
    )
    
    @constraint(model, [k in 1:G.K],
        T[k] <= T[k + G.K]
    )
    
    optimize!(model)
    
    return model, x
end


#----------------------------------------------------------------
function Exato(G::RouteType,MaxTimeSeconds::MyInt)
        
    model, x = build_pdp_model(G,MaxTimeSeconds)

    if termination_status(model) == MOI.TIME_LIMIT
        println("Time limit reached")
        if primal_status(model) != MOI.FEASIBLE_POINT
            println("Solution not found")
            return
        end
    end

    if termination_status(model) == MOI.NO_SOLUTION
        println("Solution not found")
        return
    end

    display(value.(x))

    G.BestSol[1] = 1

    seen = 1
    current = 1
    while(true)

        G.BestSol[seen] = current
    
        if seen == 2*G.K
            break
        end

        for j in 1:2*G.K
            if value(x[current, j]) == 1
                current = j
                seen += 1
                break
            end
        end
    end

    display(G.BestSol)

    return model

end
