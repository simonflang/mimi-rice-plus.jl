################################################################################
# Optimization functions - differentiated CPRICE
# ##############################################################################

function construct_RICE_objective(m::Model,t_choice::Int)

    # Find number of timesteps across model time horizon.
    n_steps = length(dim_keys(m, :time))

    # Pre-allocate matrix to store optimal tax and mitigation rates.
    MIU = ones(n_steps,12)
    MIU[1,:] .= 0

    # Create a function to optimize user-specified model for (i) revenue recycling and (ii) reference case.
    RICE_objective =

    function RICE2010Welfare(MIUvec::Array{Float64,1})
        for j = 1:12
            MIU[2:(t_choice+1),j] = MIUvec[((j-1)*t_choice+1):j*t_choice] #imposes 0 MIU in year 2005.
        end
        set_param!(m, :emissions, :MIU, MIU)
        run(m)
		return(m[:welfare, :UTILITYctryagg])  # Negishi: "UTILITY", "UTILITYctryagg"; Non-Negishi: "UTILITYNOnegishiNOrescale", "UTILITYctryaggNOnegishiNOrescale"
	end

    # Return the objective function.
    return RICE_objective
end



function retConstraint(m::Model,max_t)
    run(m)
    backstop = m[:emissions,:pbacktime][2:(max_t+1),:]
    function nlconst(result::Vector,vect::Vector)
        arr = reshape(vect,:,12)
        prices = backstop .* arr .^ 1.8
        result[:] =  std(prices,dims=2) ./ mean(prices,dims=2) .- 0.3
    end
end


################################################################################
# Optimization functions - uniform CPRICE
# ##############################################################################

function construct_nice_objective(m::Model,t_choice::Int)

    # Find number of timesteps across model time horizon.
    n_steps = length(dim_keys(m, :time))

    # Pre-allocate matrix to store optimal tax and mitigation rates.
    MIU = ones(n_steps,12)
    MIU[1,:] .= 0
							### NEW ###############################
							rice_backstop = m[:emissions,:pbacktime] #[2:(max_t+1),:]

    # Create a function to optimize user-specified model for (i) revenue recycling and (ii) reference case.
    nice_objective =

    function nice_objective(tax::Array{Float64,1})
		# Calculate emissions abatement level as a function of the carbon tax.
		abatement_level, tax = mu_from_tax(tax, rice_backstop) #, 2.8) # abatement level as a function of the tax = mu_from_tax

		setparameter(m, :emissions, :MIU, abatement_level)

        run(m)
		return(m[:welfare, :UTILITYNOnegishiNOrescale])  # Negishi: "UTILITY", "UTILITYctryagg"; Non-Negishi: "UTILITYNOnegishiNOrescale", "UTILITYctryaggNOnegishiNOrescale"
	end

    # Return the objective function.
    return nice_objective
end



function retConstraint(m::Model,max_t)
    run(m)
    backstop = m[:emissions,:pbacktime][2:(max_t+1),:]
    function nlconst(result::Vector,vect::Vector)
        arr = reshape(vect,:,12)
        prices = backstop .* arr .^ 1.8
        result[:] =  std(prices,dims=2) ./ mean(prices,dims=2) .- 0.3
    end
end


# Function to calculate emissions control rate as a function of the carbon tax.
function mu_from_tax(tax::Array{Float64,1}, rice_backstop::Array{Float64,2})
	rice_backstop = m[:emissions,:pbacktime] #[2:(max_t+1),:]
    backstop = rice_backstop .* 1000.0
    pbmax = maximum(backstop, dims=2)
    TAX = [0.0; pbmax[2:end]]
    # TAX[2:(n_steps+1)] = tax
	tax = TAX[2:(n_steps)]
    mu = min.((max.(((TAX ./ backstop) .^ (1 / (2.8 - 1.0))), 0.0)), 1.0) # 2.8 = expcost2

    return mu, TAX
end

### Direct copies from NICE

#Function to calculate emissions control rate as a function of the carbon tax.
function mu_from_tax(tax::Array{Float64,1}, backstop_p::Array{Float64,2}, theta2::Float64)
    backstop = backstop_p .* 1000.0
    pbmax = maximum(backstop, 2)
    TAX = [0.0; pbmax[2:end]]
    TAX[2:(length(tax)+1)] = tax
    mu = min((max(((TAX ./ backstop) .^ (1 / (theta2 - 1.0))), 0.0)), 1.0)

    return mu, TAX
end


# function optimize_nice
function optimize_nice(objetive_function, m::Mimi.Model, algorithm::Symbol, n_objectives::Int64, upperbound::Array{Float64,1}, stop_time::Int64, tolerance::Float64, theta2::Float64, backstop_price::Array{Float64,2})
    opt = Opt(algorithm, n_objectives)

    lower_bounds!(opt, zeros(n_objectives))
    upper_bounds!(opt, upperbound)

    max_objective!(opt, (x, grad) -> objetive_function(x))

    maxtime!(opt, stop_time)
    ftol_rel!(opt, tolerance)

    (minf,minx,ret) = optimize(opt, (upperbound .* 0.5))
    println("Convergence result: ", ret)

    mitigation, tax = mu_from_tax(minx, backstop_price, theta2)

    setparameter(m, :emissions, :MIU, mitigation)
    run(m)

    result = NICE_outputs(inputs, tax, m[:climatedynamics, :TATM], mitigation, m[:emissions, :E], m[:nice_consumption, :quintile_c], m)
    return result
end


################################################################################
# General helpers functions
# ##############################################################################

function getindexfromyear_rice_2010(year)
    baseyear = 2005

    if rem(year - baseyear, 10) != 0
        error("Invalid year")
    end

    return div(year - baseyear, 10) + 1
end

#Function to read a single parameter value from original RICE 2010 model.
function getparam_single(f, range::AbstractString, regions)
    vals= Array{Float64}(undef, length(regions))
    for (i,r) = enumerate(regions)
        data=readxl(f,"$(r)!$(range)")
        vals[i]=data[1]
    end
    return vals
end

# NEW: CCOUNTRY-LEVEL: Function to read a single parameter value for the country-level adaptations.
function getparam_single_ctry(f, range::AbstractString, countries)
    vals= Array{Float64}(undef, length(countries))
    for (i,c) = enumerate(countries)
        data=readxl(f,"$(c)!$(range)")
        vals[i]=data[1]
    end
    return vals
end

#Function to read a time series of parameter values from original RICE 2010 model.
function getparam_timeseries(f, range::AbstractString, regions, T)
    vals= Array{Float64}(undef, T, length(regions))
    for (i,r) = enumerate(regions)
        data=readxl(f,"$(r)!$(range)")
        for n=1:T
            vals[n,i] = data[n]
        end
    end
    return vals
end









# println("mu = ", mu)
# println("TAX = ", TAX)
	# println("tax = ", tax)
	# println("tax from function = ", tax)
	# println("abatement_level = ", abatement_level)
