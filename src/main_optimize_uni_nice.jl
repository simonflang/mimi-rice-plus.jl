using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV
using RCall
using NLopt
using JLD
using HDF5

include("rice2010.jl")
include("helpers.jl")
include("nice.jl")
using .Rice2010

#####################################################################################
# Things that need to be set manually
# ###################################################################################

optimization = "Yes"      # "Yes" or "No"

# Set the model version manually in the following components:
# 1) grosseconomy ("region" or "country")
# 2) neteconomy ("Burke" or "original")

# Set the optimand manually in:
# 3) nice (in "return(m[:welfare, :???])")

# Set the redistribution quantity and the redistribution scheme in:
# 4) parameters
# 5) neteconomy

# Set the pure rate of time preference in:
# 6) parameters

# Set the results directory and whether the results should be saved and plotted in:
# 7) save_and_plot

# Exponent of cost control function ( = expost2 (in the rest of the model) which is also 2.8)
theta2 = 2.8

#####################################################################################
# Non-optimization Run
# ###################################################################################

if optimization == "No"

    m, rice_params = getrice()

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


#############################
# Optimization settings
# ###########################

# Number of objectives (corresponding to how many periods in NICE to optimze over).
n_objective = 40                # 29 in RICEupdate, 10 in mimi-NICE, I always do 40 (just to be safe)

#Optimization algorithm (:symbol). See options at http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms
opt_algorithm = :LN_SBPLX      # LN_SBPLX in RICEupdate

# Maximum time in seconds to run (in case things don't converge).
stop_time = 500                 # 500 in RICEupdate, 300 in mimi-NICE

# Relative tolerance criteria for convergence (will stop if |Δf| / |f| is less than tolerance
# from one iteration to the next.)
tolerance = 1e-12               # 1e-12 in RICEupdate, 5e-12 in mimi-NICE


#############################
# Optimization model run
# ###########################

if optimization == "Yes"

    # Create a NICE objective function specific to the user parameter settings.
    nice_objective, m, rice_params  = construct_nice_objective()
    println("nice_objective_main: ", nice_objective)
    # println("x: ", m[:nice_welfare, :UTILITYNOnegishiNOrescale])


    #Extract RICE backstop price values and index/scale for NICE (used in optimization).
    backstop_opt_values = maximum(rice_params[:pbacktime], dims = 2)[2:(n_objective+1)].*1000.0 # added "dims = "
    println("backstop_opt_values_MAIN: ", backstop_opt_values) # OK

    # Optimize NICE and save the results as a custom type `NICE_outputs`.
    results = optimize_nice(nice_objective, m, opt_algorithm, n_objective, backstop_opt_values, stop_time, tolerance, theta2, rice_params[:pbacktime]) # theta2 = 2.8
    println("results_MAIN: ", results)

    explore(m)
end


include("save_and_plot.jl") # to save the model output
