
using DataFrames
using NLopt

include("components/neteconomy_component.jl")  # don't think I need this but inccluded it because it was inlcuded in NICE
include("components/welfare_component.jl")     # don't think I need this but inccluded it because it was inlcuded in NICE
include("rice2010.jl")
include("helpers.jl")
include("parameters.jl")

println("test")

using .Rice2010

#### Construct NICE

function construct_nice()

    # Construct RICE2010 and load RICE parameters
    m, rice_params = getrice()

    return m, rice_params
end




#### Create NICE objective function (Uniform CPRICE) ##############################################################################################################

# Create NICE objective function, passing in version of NICE made with "construct_nice()" function.
function construct_nice_objective()

    # Get an implementation of the NICE model
    m, rice_params = construct_nice()
    # m = getrice()

    marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
    set_param!(m,:emissions,:marginalemission,marginalemission)

    marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
    set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

    # Get backstop prices from base version of RICE
    rice_backstop =  rice_params[:pbacktime]

    function nice_objective(tax::Array{Float64,1})

        # Calculate emissions abatement level as a function of the carbon tax.
        abatement_level, tax = mu_from_tax(tax, rice_backstop, 2.8) # abatement level as a function of the tax = mu_from_tax

        set_param!(m, :emissions, :MIU, abatement_level)
        run(m)
        # explore(m) # I added this to see what's been happening
        return m[:welfare, :UTILITYNOnegishiNOrescale]      # Negishi: "UTILITY", "UTILITYctryagg"; Non-Negishi: "UTILITYNOnegishiNOrescale", "UTILITYctryaggNOnegishiNOrescale"
        println("utility: ", m[:welfare, :UTILITYNOnegishiNOrescale])
    end
    # println("utility2: ", m[:welfare, :UTILITYNOnegishiNOrescale])

    return nice_objective, m, rice_params
    println("nice_objective: ", nice_objective)
end
# println("nice_objective2: ", nice_objective)




#### Create NICE objective function (Uniform CPRICE + Foreign Abatement) ##############################################################################################################

# Create NICE objective function, passing in version of NICE made with "construct_nice()" function.
function construct_nice_objective_FA()

    # Get an implementation of the NICE model
    m, rice_params = construct_nice()
    # m = getrice()

    marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
    set_param!(m,:emissions,:marginalemission,marginalemission)

    marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
    set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

    # Get backstop prices from base version of RICE
    rice_backstop =  rice_params[:pbacktime]

    function nice_objective_FA(tax::Array{Float64,1})

        # Calculate emissions abatement level as a function of the carbon tax.
        abatement_level, tax = mu_from_tax_FA(tax, rice_backstop, 2.8) # abatement level as a function of the tax = mu_from_tax_FA

        set_param!(m, :emissions, :MIU, abatement_level)
        run(m)
        # explore(m) # I added this to see what's been happening
        return m[:welfare, :UTILITYNOnegishiNOrescale]      # Negishi: "UTILITY", "UTILITYctryagg"; Non-Negishi: "UTILITYNOnegishiNOrescale", "UTILITYctryaggNOnegishiNOrescale"
        println("utility: ", m[:welfare, :UTILITYNOnegishiNOrescale])
    end
    # println("utility2: ", m[:welfare, :UTILITYNOnegishiNOrescale])

    return nice_objective_FA, m, rice_params
    println("nice_objective_FA: ", nice_objective_FA)
end
# println("nice_objective_FA2: ", nice_objective_FA)
