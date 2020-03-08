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
        return(m[:welfare, :welfare])
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
