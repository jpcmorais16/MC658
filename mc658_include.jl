const MyInt = Int64

const NodeIdType = MyInt
const PositionType = MyInt
const CostType = MyInt
const TimeType = MyInt

mutable struct NodeType
    id ::NodeIdType
    px ::PositionType
    py ::PositionType
	function NodeType()
		NodeType(-1,-1,-1)
	end
	# Constructor of a node
	function NodeType(a::NodeIdType, px::PositionType, py::PositionType)
		new(a,px,py)
	end
end

# Random integer in hte interval [ I , F ], including I and F.
function MyRand(I::MyInt , F::MyInt)
	return(Int(floor(rand()*(F-I+1))+I))
end

# In the RouteType, given K (number of pairs) and Seed (a seed for the random number generator),
# all the other informations in the structure are calculated.
mutable struct RouteType 
	K::MyInt				# Number of pairs
	StartingSeed::MyInt		# Seed for the Random Number generator
	NNodes::MyInt			# Total number of nodes (NNodes = 2*K)
	Pos::MyInt
	# For the next line, at this point, we dont need to give the number of elements,
	# but only say that Node will be a vector of NodeType. In the next constructor function
	# we will generate something that will be the memory used by the vector Node
	Node::Array{NodeType,1} # Node[i] contains inform. of node i: id and coordinate position
	Dist::Array{MyInt,2}	# Dist[i,j] is the distance of arc (i --> j)
	Time::Array{MyInt,2}	# Time[i,j] is the time to traverse arc ( i--> j)
	Delta::Array{MyInt,1}   # Delta[i] is the maximum time from the time to
	                        # pick in node i and delivery at the node i+K.
				            # It is an array of K positions, 
	BestValue::MyInt
	BestSol::Vector{MyInt}

	# Constructor of the VRP Instance. It is sufficient to give
	# the number of pairs and a seed
	function RouteType(_K::MyInt,_StartingSeed::MyInt,DistFactor,TimeFactor)
		# To make the association easier, the variables of this function that
		# will be sent to the route fields have the same name, but starting with 
		# an underscore
		Random.seed!(_StartingSeed)
		# Each variable is related to a field. To make correspondence easy,
		# the variables below have the symbol "_" before the corresponding field
		_Node::Vector{NodeType} =  Vector{NodeType}(undef,2*_K)
		# Total number of nodes is the double of the pairs
		# We will define the
		# source as the node in position 1 and the
		# target is the node in position 1+K
		_NNodes=2*_K
		# Generate the Distance matrix, which is a 2-dimensional array
		# where the element Dist[i,j] has the distance of the arc (i-->j).
		for i in 1:_NNodes
			_Node[i]=NodeType(i,MyRand(1,10000),MyRand(1,10000))
		end
		# Will be the matrix of distance
		_Dist = Array{MyInt,2}(undef,_NNodes,_NNodes) 
		_Time = Array{MyInt,2}(undef,_NNodes,_NNodes)
		MaxTime = 0
		for i in 1:_NNodes
			for j in 1:_NNodes
			    Distance = Int64(floor(sqrt((_Node[i].px-_Node[j].px)^2+(_Node[i].py-_Node[j].py)^2) + 1.0))
			    if (Distance==0)
			       Distance = 1
			    end
			    # change the distance to include some randomness
			    # perhaps it makes the problem more challenging.
			    _Dist[i,j] = Int64(floor(Distance*(1+DistFactor*rand())))
			    # The time is basically the distance multiplied by a factor of 100, plus
			    # some randomness bounded by 50% of the time
			    _Time[i,j] = Int64(floor(100*Distance*(1+TimeFactor*rand())))
			    if (_Time[i,j] > MaxTime)
			       MaxTime = _Time[i,j]
			    end
			end
		end
		_Delta = Array{MyInt,1}(undef,_K)
		# Change the time requirement from the source (Node 1) to target (Node 1+K)
		# so that its time requirement is always sufficient.
		_Delta[1] = 2*_NNodes*MaxTime

		for i in 2:_K
		    _Delta[i] = Int64(floor(_Time[i,i+_K]*(1.0+TimeFactor*rand())))
		end
		

		# Generate a feasible solution
		_BestSol::Vector{MyInt} =  Vector{MyInt}(undef,_NNodes)
		_BestValue = 0
		_BestSol[1] = 1 # first node
		for i in 1:_K-1
		    _BestSol[2*i] = i+1
		    _BestSol[2*i+1] = i+1+_K
		end
		_BestSol[_NNodes] = 1+_K # last node is the target node
		for i in 1:_NNodes-1
		    _BestValue = _BestValue + _Dist[i,i+1]
		end

		Aux::MyInt = MyRand(1,10000)
		BestV = new(_K,_StartingSeed,_NNodes,Aux,_Node,_Dist,_Time,_Delta,_BestValue,_BestSol)
	end
end
#-------------------------------------------------------------------

function PrintInstance(R::RouteType)
	println("#-------------------------------------------------")
	println("# Inicio da impressao da entrada.")
	println("# Linhas que comecam com '#' sao comentarios.")
	println("# Instancia do problema de Coleta e Entrega")
	println("# Gerada com StartingSeed: ",R.StartingSeed)
	println("#")
	println("# Grafo com ",R.K," pares de coleta-entrega e ",2*R.K," vertices no total")
	println("# Pares ( i, i+",R.K,").")
	println("# K\tN\t# K=pares pickup-delivery, N=numero total de vertices")
	println(R.K,"\t",R.NNodes,"\t# Num_Pares=",R.K,", Num_Total_Vertices=",R.NNodes,". V={1,...,",R.NNodes,"}")
	println("#")
	println("# Pares de nós Pickup-Delivery e tempo maximo para a correspondente entrega.")
	println("# Pick\tDelivery\tTempoMaximo")
	for i in 1:R.K
		println(i,"\t",i+R.K,"\t",R.Delta[i])
	end
	println("#")
	println("# Lista de cada arco i-->j, seu custo e seu tempo de deslocamento")
	println("# i\tj\tc_ij\tt_ij")
	for i in 1:R.NNodes
	    for j in 1:R.NNodes
	    	if (i!=j)
		   println(i,"\t",j,"\t",R.Dist[i,j],"\t",R.Time[i,j])
		end
	    end
	end
	println("# Fim da impressao da entrada.")
	println("")
end

#-------------------------------------------------------------------
# Rotinas para plotar solucao
function PlotEdge!(plt,x1,y1,x2,y2)
	 plot!(plt,[x1,x2],[y1,y2])
end

function PlotNode!(plt,x,y,NodeLabel,color,fontsize)
	 plot!(plt,[x],[y]; marker=(:circle,fontsize+2,color))
	 plot!(plt,annotate!([(x, y, text(NodeLabel,fontsize))]))
end

function PlotSource!(plt,x,y,NodeLabel,color,fontsize)
	 plot!(plt,[x],[y]; marker=(:circle,fontsize+2,color))
	 plot!(plt,annotate!([(x, y, text(NodeLabel,fontsize))]))
end

function PlotTarget!(plt,x,y,NodeLabel,color,fontsize)
	 plot!(plt,[x],[y]; marker=(:square,fontsize,color))
	 plot!(plt,annotate!([(x, y, text(NodeLabel,fontsize))]))
end

function PlotText!(plt,x,y,textstring,color,fontsize)
	 plot!(plt,annotate!([(x, y, text(textstring,fontsize))]))
end

function SaveBestRoutePDF(G::RouteType,PDFfilename)
	 MaxX = -1000000000
	 MinX = +1000000000
	 MaxY = -1000000000
	 MinY = +1000000000
	 for i in 1:2*G.K
	     if MaxX<G.Node[i].px
	     	MaxX=G.Node[i].px
	     end
	     if MaxY<G.Node[i].py
	        MaxY=G.Node[i].py
    	     end
	     if MinX>G.Node[i].px
	        MinX=G.Node[i].px
	     end
	     if MinY>G.Node[i].py
	        MinY=G.Node[i].py
	     end
	 end
	 DeltaX=(MaxX-MinX)*0.05
	 DeltaY=(MaxY-MinY)*0.05
	 if DeltaX==0
	    DeltaX=5
	 end
	 if DeltaY==0
	    DeltaY=5
	 end
	 MinX=MinX-DeltaX
	 MaxX=MaxX+DeltaX
	 MinY=MinY-DeltaY-DeltaY
	 MaxY=MaxY+DeltaY
	 
	 plt = plot(axis=nothing,bordercolor="white",legend=false,xlim=(MinX,MaxX),ylim=(MinY,MaxY))

	 TotalCost=0
	 for i in 2:2*G.K
	     u=G.BestSol[i-1]
	     v=G.BestSol[i]
	     PlotEdge!(plt,G.Node[u].px,G.Node[u].py,G.Node[v].px,G.Node[v].py)
	     TotalCost = TotalCost + G.Dist[u,v]
	 end
	 PlotText!(plt,MinX+(MaxX-MinX)/2,MinY,"Custo da Solucao "*string(TotalCost)*".",colorant"black",8)	 

	 # println("Source[",1,"](",G.Node[1].px,",",G.Node[1].py,") ")
	 PlotSource!(plt,G.Node[1].px,G.Node[1].py,string(1),colorant"red",5)
	 for i in 2:G.K
	     #println("Source[",i,"] (",G.Node[i].px,",",G.Node[i].py,") ")
	     PlotSource!(plt,G.Node[i].px,G.Node[i].py,string(i),colorant"orange",5)
	     #println("Target[",i,"] (",G.Node[i+G.K].px,",",G.Node[i+G.K].py,") ")
	     PlotTarget!(plt,G.Node[i+G.K].px,G.Node[i+G.K].py,string(i),colorant"cyan",5)
	 end
	 #println("Target[",1,"] (",G.Node[1+G.K].px,",",G.Node[1+G.K].py,") ")
	 PlotTarget!(plt,G.Node[1+G.K].px,G.Node[1+G.K].py,string(1),colorant"red",5)
	 savefig(plt,PDFfilename) 

end
#-------------------------------------------------------------------

# imprime o valor da solucao (a ideia eh trocar por uma que tambem faz verificacao)
function GetBestSolCost(G::RouteType)
	 TotalCost=0
	 for i in 2:2*G.K
	     u=G.BestSol[i-1]
	     v=G.BestSol[i]
	     TotalCost = TotalCost + G.Dist[u,v]
	 end
	 return(TotalCost)
end

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--ra"
            help = "academic number"
	    arg_type = Int
	    required = true
        "--npairs"
            help = "number of pairs"
	    arg_type = Int
	    required = true
        "--seed"
            help = "seed for the random number generator"
	    arg_type = Int
	    required = true
        "--time"
            help = "maximum time, in seconds"
            arg_type = Int
	    required = true
        "--distfactor"
            help = "distant factor (e.g., 0.5)"
	    arg_type = Float64
	    required = true
        "--timefactor"
            help = "time factor (e.g., 4)"
	    arg_type = Float64
	    required = true
    end
    return parse_args(s)
end

function getparameters()
    RA = 999999
    npairs = 0
    tempo = 0
    distfactor = 0.0
    timefactor = 0.0
    seednumber = 0
    parsed_args = parse_commandline()
    for (arg,val) in parsed_args
        #println("$arg=>$val")
	if "$arg"=="time"
	   tempo=parse(MyInt,"$val")
	end
	if "$arg"=="ra"
	   RA=parse(MyInt,"$val")
	end
	if "$arg"=="npairs"
	   npairs=parse(MyInt,"$val")
	end
	if "$arg"=="distfactor"
	   distfactor=parse(Float64,"$val")
	end
	if "$arg"=="timefactor"
	   timefactor=parse(Float64,"$val")
	end
	if "$arg"=="seed"
	   seednumber=parse(Int64,"$val")
	end
    end
    return(RA,npairs,tempo,distfactor,timefactor,seednumber)
end


function DummyHeuristicCost(G::RouteType,H::Vector{MyInt})
   TotalCost=0
   TotalCost = TotalCost + G.Dist[1,H[2]] # Add cost from P[1] to P[H[2]]
   for i in 2:G.K-1
      TotalCost = TotalCost + G.Dist[H[i],H[i]+G.K] # Add cost from P[H[i]] to D[H[i]]
      TotalCost = TotalCost + G.Dist[H[i]+G.K,H[i+1]] # Add cost from D[H[i]] to P[H[i+1]]
   end
   TotalCost = TotalCost + G.Dist[H[G.K],H[G.K]+G.K] # Add cost from P[H[i]] to D[H[i]]
   TotalCost = TotalCost + G.Dist[H[G.K]+G.K,1+G.K] # Add cost from D[H[G.K]] to D[1]
   return(TotalCost)
end


# So' para exemplificar uma heuristica simples
function DummyHeuristic(G::RouteType,MaxTimeSeconds::MyInt)
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
	 
	 # H guarda a sequencia heuristica
	 H::Vector{MyInt} =  Vector{MyInt}(undef,G.K)

	 # Comeca com uma solucao dada por
	 #           P[1]->P[2]->D[2]->P[3]->D[3]->...->P[K]->D[K]->D[1]
	 for i in 1:G.K
	     H[i] = i
	 end

	 CurrBestSolutionValue = DummyHeuristicCost(G,H)
	 # Itera enquanto tiver tempo
	 while (((time()-StartingTimeSeconds))<MaxTimeSeconds)
	       #println("Tempo sobrando = ",(time()-StartingTimeSeconds),"s.")
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
	if (CurrBestSolutionValue < G.BestValue)
	   #println("Solucao heuristica melhorou de ",G.BestValue," para ",CurrBestSolutionValue,".")
	   G.BestValue = CurrBestSolutionValue
	   G.BestSol[1] = 1 # first node
	   for i in 1:G.K-1
	       G.BestSol[2*i] = H[i+1]
	       G.BestSol[2*i+1] = H[i+1]+G.K
	   end
	   G.BestSol[G.NNodes] = 1+G.K # last node is the target node
	end
end     

