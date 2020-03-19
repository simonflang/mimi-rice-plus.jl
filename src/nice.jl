
using DataFrames
using NLopt

include("rice2010.jl")
include("helpers.jl")

using .Rice2010

#### Create NICE objective function ##############################################################################################################

# Create NICE objective function, passing in version of NICE made with "construct_nice()" function.
function construct_nice_objective(inputs::NICE_inputs)

    # Get an implementation of the NICE model
    m, rice_params = construct_nice(inputs)

    # Get backstop prices from base version of RICE
    rice_backstop = rice_params[:pbacktime]

    function nice_objective(tax::Array{Float64,1})

        # Calculate emissions abatement level as a function of the carbon tax.
        abatement_level, tax = mu_from_tax(tax, rice_backstop, 2.8) # abatement level as a function of the tax = mu_from_tax

        setparameter(m, :emissions, :MIU, abatement_level)
        run(m)
        return m[:nice_welfare, :welfare]
    end

    return nice_objective, m, rice_params
end
