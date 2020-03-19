using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV
using RCall
using NLopt

include("rice2010.jl")
include("helpers.jl")
include("nice.jl")
using .Rice2010

## Things that need to be set manually

optimization = "Yes"      # "Yes" or "No"

# Set the model version manually in the following components:
# 1) grosseconomy
# 2) neteconomy

# Set the optimand manually in:
# 3) helpers (in "return(m[:welfare, :???])")

# Set the redistribution quantity in:
# 4) parameters

# Set the results directory and whether the results should be saved and plotted in:
# 5) save_and_plot

#####################################################################################
# Non-optimization Run
# ###################################################################################

if optimization == "No"

    m = getrice()

    marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
    set_param!(m,:emissions,:marginalemission,marginalemission)

    marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
    set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

    run(m)
    explore(m)

end

####################################################################################
# Optimization Run
# ##################################################################################


####################################################################################################
# OPTIMIZATION SETTINGS
# ###################################################################################################

# Number of objectives (corresponding to how many periods in NICE to optimze over).
n_objective = 10

#Optimization algorithm (:symbol). See options at http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms
opt_algorithm = :LN_BOBYQA

# Maximum time in seconds to run (in case things don't converge).
stop_time = 300

# Relative tolerance criteria for convergence (will stop if |Δf| / |f| is less than tolerance
# from one iteration to the next.)
tolerance = 5e-12


####################################################################################################
# Optimization Run.
####################################################################################################
if optimization == "Yes"

    # Create a NICE objective function specific to the user parameter settings.
    nice_objective, m, rice_params = construct_nice_objective(inputs)

    #Extract RICE backstop price values and index/scale for NICE (used in optimization).
    backstop_opt_values = maximum(rice_params[:pbacktime], 2)[2:(n_objective+1)].*1000.0

    # Optimize NICE and save the results as a custom type `NICE_outputs`.
    results = optimize_nice(nice_objective, m, opt_algorithm, n_objective, backstop_opt_values, stop_time, tolerance, theta2, rice_params[:pbacktime])



### my OLD code
    m = getrice()

    marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
    set_param!(m,:emissions,:marginalemission,marginalemission)

    marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
    set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

    run(m)


    explore(m)

    # return TAX

end


include("save_and_plot.jl") # to save the model output
