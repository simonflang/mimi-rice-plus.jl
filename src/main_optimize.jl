using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV
using RCall
using NLopt

include("rice2010.jl")
include("helpers.jl")
using .Rice2010

#####################################################################################
# Things that need to be set manually
# ###################################################################################

optimization = "Yes"      # "Yes" or "No"

# Set the model version manually in the following components:
# 1) grosseconomy ("region" or "country")
# 2) neteconomy ("Burke" or "original")

# Set the optimand manually in:
# 3) helpers (in "return(m[:welfare, :???])")

# Set the redistribution quantity and the rdistribution scheme in:
# 4) parameters
# 5) neteconomy

# Set the pure rate of time preference in:
# 6) parameters

# Set the results directory and whether the results should be saved and plotted in:
# 7) save_and_plot

#####################################################################################
# Non-optimization Run
# ###################################################################################

if optimization == "Yes"

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

if optimization == "Yes"

    m, rice_params = getrice()

    marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
    set_param!(m,:emissions,:marginalemission,marginalemission)

    marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
    set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

    run(m)


    ## RICE Update code

    # Load RICE+AIR source code.
    # include("mRICE2010.jl")

    # this is how you initiate an instance m of the model
    # m = get_rice() #default if get_rice(objective = "Neutral") set objective = "Negishi" for that objective
    # then you run the model
    # run(m)

    # say you want to change some parameter
    #like the discount rate
    # m[:welfare,:rho] = 1.5
    #or the mitigation fraction, this is how we input the control variable in the optimisation
    # m[:emissions,:MIU] = 0.5*ones(60,12)

    # the way the optimisation works is that we construc the model, and set a bunch of user defined paramaters, and from that construct the objective

    # mod = get_rice()  # this line seems to do nothing (SL commented it out)

    # number of periods of control
    t_choice = 40            # 29 in RICEupdate, 10 in mimi-NICE, I always do 40 (just to be safe), maximum is 59
    # Maximum time in seconds to run local optimization (in case optimization does not converge).
    local_stop_time = 500
    # Relative tolerance criteria for global optimization convergence (will stop if |Δf| / |f| < tolerance from one iteration to the next.)
    local_tolerance = 1e-12
    objective = construct_RICE_objective(m,t_choice)
    constraint = retConstraint(m,t_choice)
    # set up optimisation# Create an NLopt optimization object.
    opt_object = Opt(:LN_SBPLX, t_choice*12)
    # set up constraint

    # bounds on the control variable
    lower_bounds!(opt_object, zeros(12*t_choice))
    upper_bounds!(opt_object, ones(12*t_choice))
    # Set maximum run time.
    maxtime!(opt_object, local_stop_time)
    # Set convergence tolerance.
    ftol_rel!(opt_object, local_tolerance)
    # Set objective function.
    max_objective!(opt_object, (x, grad) -> objective(x))
    # inequality_constraint!(opt_object, (x, grad) -> constraint(x)-0.5) # I commented it out because it throws the following error "ArgumentError: invalid NLopt arguments: invalid algorithm for constraints"
    max_welfare, optimal_rates, convergence_flag = optimize(opt_object, 0.5*ones(12*t_choice))

    explore(m)

end


include("save_and_plot.jl") # to save the model output
