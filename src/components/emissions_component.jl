using Mimi

global foreignabatement = "H4-L8-GDPpre-cond-uniCPRICE"        # "none", "H4-L8-GDPpre-cond-diffCPRICE", "H4-L8-GDPpre-cond-uniCPRICE"

@defcomp emissions begin
    regions = Index()
    countries = Index()

    E = Variable(index=[time]) # Total CO2 emissions (GtC per year)
    EIND = Variable(index=[time, regions]) # Industrial emissions (GtC per year)
    CCA = Variable(index=[time]) # Cumulative indiustrial emissions
    ABATECOST = Variable(index=[time, regions]) # Cost of emissions reductions  (trillions 2005 USD per year)
    MCABATE = Variable(index=[time, regions]) # Marginal cost of abatement (2005$ per ton CO2)
    CPRICE = Variable(index=[time, regions]) # Carbon price (2005$ per ton of CO2)

    sigma = Parameter(index=[time, regions]) # CO2-equivalent-emissions output ratio
    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    etree = Parameter(index=[time]) # Emissions from deforestation
    cost1 = Parameter(index=[time, regions]) # Adjusted cost for backstop
    expcost2 = Parameter(index=[regions]) # Exponent of control cost function
    partfract = Parameter(index=[time, regions]) # Fraction of emissions in control regime
    pbacktime = Parameter(index=[time, regions]) # Backstop price
    MIU = Parameter(index=[time, regions]) # Emission control rate GHGs

    # NEW: COUNTRY-LEVEL
    ABATECOSTctry = Variable(index=[time, countries]) # Cost of emissions reductions  (trillions 2005 USD per year)
    YGROSSctry = Parameter(index=[time, countries]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to

    # NEW: Marginal emission for SCC calculation
    marginalemission = Parameter() # "1" if there is an additional marginal emissions pulse, "0" otherwise

    # NEW: Foreign abatement
    ABATECOSTforeign = Variable(index=[time, regions])
    ABATECOSTforeignpotential = Variable(index=[time, regions])
    ABATECOSTpotential = Variable(index=[time, regions])
    ABATECOSTtotal = Variable(index=[time, regions])
    MIUtotal = Variable(index=[time, regions])
    MIUtotalcalc = Variable(index=[time, regions])
    MIUforeign = Variable(index=[time, regions])
    MIUforeigncalc = Variable(index=[time, regions])
    EINDforeign = Variable(index=[time, regions])
    EINDdomestic = Variable(index=[time, regions])
    MCABATEtotal = Variable(index=[time, regions]) # Marginal cost of abatement for the whole economy (2005$ per ton CO2)
    CPRICEtotal = Variable(index=[time, regions]) # Hypothetical Carbon price for the whole economy(2005$ per ton of CO2)

    # NEW: Redistribution
    REDISTbase = Parameter(index=[time]) # Redistribution in the base year (trillions 2005 USD per year) - for some redistribution schemes, the actual redistribution quantity grows relative to the base quantity
    REDIST = Variable(index=[time]) # Actual redistribution (trillions 2005 USD per year)
    REDISTpotential = Variable(index=[time]) # Potential redistribution (trillions 2005 USD per year)
    REDISTreg = Variable(index=[time, regions]) # Regional Redistribution (trillions 2005 USD per year)
    REDISTregpotential = Variable(index=[time, regions]) # Potential Regional Redistribution (trillions 2005 USD per year)
    l = Parameter(index=[time, regions]) # Level of population and labor
    YNET = Parameter(index=[time, regions]) # Output net of damages equation (trillions 2005 USD per year)


    function run_timestep(p, v, d, t)

        if foreignabatement == "none"

            #Define function for EIND
            for r in d.regions
                v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
            end

            #Define function for E
            if p.marginalemission == 0
                v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
            elseif p.marginalemission == 1
                if t.t == 2
                    v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
                else
                    v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
                end
            else
                println("no marginal emissions")
            end

            #Define function for CCA
            if is_first(t)
                v.CCA[t] = sum(v.EIND[t,:]) * 10.
            else
                v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
            end

            #Define function for ABATECOST
            for r in d.regions
                v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
            end

            # NEW: COUNTRY-LEVEL: Define function for ABATECOST
            for c in d.countries
                if p.inregion[c] == 1
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,1] * (p.MIU[t,1]^p.expcost2[1]) * (p.partfract[t,1]^(1 - p.expcost2[1]))
                elseif p.inregion[c] == 2
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,2] * (p.MIU[t,2]^p.expcost2[2]) * (p.partfract[t,2]^(1 - p.expcost2[2]))
                elseif p.inregion[c] == 3
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,3] * (p.MIU[t,3]^p.expcost2[3]) * (p.partfract[t,3]^(1 - p.expcost2[3]))
                elseif p.inregion[c] == 4
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,4] * (p.MIU[t,4]^p.expcost2[4]) * (p.partfract[t,4]^(1 - p.expcost2[4]))
                elseif p.inregion[c] == 5
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,5] * (p.MIU[t,5]^p.expcost2[5]) * (p.partfract[t,5]^(1 - p.expcost2[5]))
                elseif p.inregion[c] == 6
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,6] * (p.MIU[t,6]^p.expcost2[6]) * (p.partfract[t,6]^(1 - p.expcost2[6]))
                elseif p.inregion[c] == 7
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,7] * (p.MIU[t,7]^p.expcost2[7]) * (p.partfract[t,7]^(1 - p.expcost2[7]))
                elseif p.inregion[c] == 8
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,8] * (p.MIU[t,8]^p.expcost2[8]) * (p.partfract[t,8]^(1 - p.expcost2[8]))
                elseif p.inregion[c] == 9
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,9] * (p.MIU[t,9]^p.expcost2[9]) * (p.partfract[t,9]^(1 - p.expcost2[9]))
                elseif p.inregion[c] == 10
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,10] * (p.MIU[t,10]^p.expcost2[10]) * (p.partfract[t,10]^(1 - p.expcost2[10]))
                elseif p.inregion[c] == 11
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,11] * (p.MIU[t,11]^p.expcost2[11]) * (p.partfract[t,11]^(1 - p.expcost2[11]))
                elseif p.inregion[c] == 12
                    v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,12] * (p.MIU[t,12]^p.expcost2[12]) * (p.partfract[t,12]^(1 - p.expcost2[12]))
                else
                    println("country does not belong to any region")
                end
            end

            #Define function for MCABATE
            for r in d.regions
                v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
            end

            #Define function for CPRICE
            # This I can change to an increasing carbon price
            for r in d.regions
                v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
            end


        elseif foreignabatement == "H4-L8-GDPpre-cond-diffCPRICE"

            for r in d.regions

                if t.t == 1

                    # v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))   # note REDISTbase[1] is 0 by default
                    # v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                    # v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                    # v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

                    v.REDISTregpotential[t,1] = 0
                    v.REDISTregpotential[t,2] = 0
                    v.REDISTregpotential[t,3] = 0
                    v.REDISTregpotential[t,11] = 0

                    v.REDISTpotential[t] = p.REDISTbase[t]       # note REDISTbase[1] is 0 by default, so REDIST[1] is 0 by default

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                elseif t.t == 2

                    v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    v.REDISTpotential[t] = p.REDISTbase[t]

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                else
                    v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (p.YNET[2,1]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,1]/p.YNET[2,1])
                    v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (p.YNET[2,2]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,2]/p.YNET[2,2])
                    v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (p.YNET[2,3]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,3]/p.YNET[2,3])
                    v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (p.YNET[2,11]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,11]/p.YNET[2,11])

                    v.REDISTpotential[t] = p.REDISTbase[t] * (p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]) / (p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])
                    # v.REDISTpotential[t] = v.REDISTregpotential[t,1] + v.REDISTregpotential[t,2] + v.REDISTregpotential[t,3] + v.REDISTregpotential[t,11]

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                end
            end

            ###################################################################################################################################
            ################### Third  VERSION  ###############################################################################################
            ###################################################################################################################################


            for r in d.regions
               if v.REDISTregpotential[t,r] > 0
                    v.ABATECOSTforeignpotential[t,r] = v.REDISTregpotential[t,r]
               else
                    v.ABATECOSTforeignpotential[t,r] = 0
               end
               # println("v.ABATECOSTforeignpotential[t,r]", v.ABATECOSTforeignpotential[t,r])
            end



            for r in d.regions
                # v.ABATECOSTtotal[t,r] = v.ABATECOST[t,r] + v.ABATECOSTforeignpotential[t,r]

                v.MIUforeigncalc[t,r] = (v.ABATECOSTforeignpotential[t,r] / (p.YGROSS[t,r] * p.cost1[t,r])) ^ (1/p.expcost2[r])

                if v.MIUforeigncalc[t,r] <= 1
                    v.MIUforeign[t,r] = v.MIUforeigncalc[t,r]
                else
                    v.MIUforeign[t,r] = 1
                end
            end

                # v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
            for r in d.regions
                v.ABATECOSTtotal[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r] + v.MIUforeign[t,r])^p.expcost2[r]
            end

            for r in d.regions
                v.ABATECOSTpotential[t,r] = v.ABATECOSTtotal[t,r] - v.ABATECOSTforeignpotential[t,r]
            end


                    # NEW: COUNTRY-LEVEL: Define function for ABATECOST  - need to CHANGE that (does not take into account foreign abatement yet)
                    for c in d.countries
                        if p.inregion[c] == 1
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,1] * (p.MIU[t,1]^p.expcost2[1]) * (p.partfract[t,1]^(1 - p.expcost2[1]))
                        elseif p.inregion[c] == 2
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,2] * (p.MIU[t,2]^p.expcost2[2]) * (p.partfract[t,2]^(1 - p.expcost2[2]))
                        elseif p.inregion[c] == 3
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,3] * (p.MIU[t,3]^p.expcost2[3]) * (p.partfract[t,3]^(1 - p.expcost2[3]))
                        elseif p.inregion[c] == 4
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,4] * (p.MIU[t,4]^p.expcost2[4]) * (p.partfract[t,4]^(1 - p.expcost2[4]))
                        elseif p.inregion[c] == 5
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,5] * (p.MIU[t,5]^p.expcost2[5]) * (p.partfract[t,5]^(1 - p.expcost2[5]))
                        elseif p.inregion[c] == 6
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,6] * (p.MIU[t,6]^p.expcost2[6]) * (p.partfract[t,6]^(1 - p.expcost2[6]))
                        elseif p.inregion[c] == 7
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,7] * (p.MIU[t,7]^p.expcost2[7]) * (p.partfract[t,7]^(1 - p.expcost2[7]))
                        elseif p.inregion[c] == 8
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,8] * (p.MIU[t,8]^p.expcost2[8]) * (p.partfract[t,8]^(1 - p.expcost2[8]))
                        elseif p.inregion[c] == 9
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,9] * (p.MIU[t,9]^p.expcost2[9]) * (p.partfract[t,9]^(1 - p.expcost2[9]))
                        elseif p.inregion[c] == 10
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,10] * (p.MIU[t,10]^p.expcost2[10]) * (p.partfract[t,10]^(1 - p.expcost2[10]))
                        elseif p.inregion[c] == 11
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,11] * (p.MIU[t,11]^p.expcost2[11]) * (p.partfract[t,11]^(1 - p.expcost2[11]))
                        elseif p.inregion[c] == 12
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,12] * (p.MIU[t,12]^p.expcost2[12]) * (p.partfract[t,12]^(1 - p.expcost2[12]))
                        else
                            println("country does not belong to any region")
                        end
                    end


            for r in d.regions
                v.MIUtotalcalc[t,r] = p.MIU[t,r] + v.MIUforeign[t,r]

                if v.MIUtotalcalc[t,r] <= 1
                    v.MIUtotal[t,r] = v.MIUtotalcalc[t,r]
                else
                    v.MIUtotal[t,r] = 1
                end
            end

            for r in d.regions
                v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUtotal[t,r])
                v.EINDforeign[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUforeign[t,r])
                v.EINDdomestic[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
            end


            for r in d.regions
                #Define function for E
                if p.marginalemission == 0
                    v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
                elseif p.marginalemission == 1
                    if t.t == 2
                        v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
                    else
                        v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
                    end
                else
                    println("no marginal emissions")
                end
            end

            for r in d.regions
                #Define function for CCA
                if is_first(t)
                    v.CCA[t] = sum(v.EIND[t,:]) * 10.
                else
                    v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
                end
            end

            for r in d.regions
                if v.ABATECOSTforeignpotential[t,r] <= v.ABATECOSTtotal[t,r]
                    v.ABATECOSTforeign[t,r] = v.ABATECOSTforeignpotential[t,r]
                else
                    v.ABATECOSTforeign[t,r] = v.ABATECOSTtotal[t,r]
                end

                v.ABATECOST[t,r] = v.ABATECOSTtotal[t,r] - v.ABATECOSTforeign[t,r]
            end


            # Define actual REDISTreg
            for r in d.regions
                v.REDIST[t] = v.ABATECOSTforeign[t,6] + v.ABATECOSTforeign[t,7] + v.ABATECOSTforeign[t,9] + v.ABATECOSTforeign[t,12] + v.ABATECOSTforeign[t,4] + v.ABATECOSTforeign[t,5] + v.ABATECOSTforeign[t,8] + v.ABATECOSTforeign[t,10]

                if t.t == 1
                    v.REDISTreg[t,1] = 0
                    v.REDISTreg[t,2] = 0
                    v.REDISTreg[t,3] = 0
                    v.REDISTreg[t,11] = 0

                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]

                elseif t.t == 2
                    v.REDISTreg[t,1] = - v.REDIST[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,2] = - v.REDIST[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,3] = - v.REDIST[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,11] = - v.REDIST[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]

                else
                    v.REDISTreg[t,1] = - v.REDIST[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,2] = - v.REDIST[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,3] = - v.REDIST[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,11] = - v.REDIST[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]
                end
            end


            #Define function for MCABATE
            # OLD
                # for r in d.regions
                #     v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
                # end

            # NEW
            for r in d.regions
                if p.MIU[t,r] == 0
                    v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
                else
                    v.MCABATE[t,r] = p.pbacktime[t,r] * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
                end
            end

            #Define function for CPRICE
            # This I can change to an increasing carbon price
                #OLD
                # for r in d.regions
                #     v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
                # end

            # NEW
            for r in d.regions
                if p.MIU[t,r] == 0
                    v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
                else
                    v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
                end
            end


            # NEW MCABATE for the whole economy (considering foreign and domestic abatement)
            for r in d.regions
                v.MCABATEtotal[t,r] = p.pbacktime[t,r] * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
            end

            # NEW CPRICE for the whole economy (considering foreign and domestic abatement)
            for r in d.regions
                v.CPRICEtotal[t,r] = p.pbacktime[t,r] * 1000 * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
            end


        elseif foreignabatement == "H4-L8-GDPpre-cond-uniCPRICE"

            for r in d.regions

                if t.t == 1

                    # v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))   # note REDISTbase[1] is 0 by default
                    # v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                    # v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                    # v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

                    v.REDISTregpotential[t,1] = 0
                    v.REDISTregpotential[t,2] = 0
                    v.REDISTregpotential[t,3] = 0
                    v.REDISTregpotential[t,11] = 0

                    v.REDISTpotential[t] = p.REDISTbase[t]       # note REDISTbase[1] is 0 by default, so REDIST[1] is 0 by default

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                elseif t.t == 2

                    v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    v.REDISTpotential[t] = p.REDISTbase[t]

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                else
                    v.REDISTregpotential[t,1] = - p.REDISTbase[t] * (p.YNET[2,1]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,1]/p.YNET[2,1])
                    v.REDISTregpotential[t,2] = - p.REDISTbase[t] * (p.YNET[2,2]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,2]/p.YNET[2,2])
                    v.REDISTregpotential[t,3] = - p.REDISTbase[t] * (p.YNET[2,3]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,3]/p.YNET[2,3])
                    v.REDISTregpotential[t,11] = - p.REDISTbase[t] * (p.YNET[2,11]/(p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])) * (p.YNET[t-1,11]/p.YNET[2,11])

                    v.REDISTpotential[t] = p.REDISTbase[t] * (p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]) / (p.YNET[2,1] + p.YNET[2,2] + p.YNET[2,3] + p.YNET[2,11])
                    # v.REDISTpotential[t] = v.REDISTregpotential[t,1] + v.REDISTregpotential[t,2] + v.REDISTregpotential[t,3] + v.REDISTregpotential[t,11]

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTregpotential[t,6] = v.REDISTpotential[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,7] = v.REDISTpotential[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,9] = v.REDISTpotential[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,12] = v.REDISTpotential[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,4] = v.REDISTpotential[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,5] = v.REDISTpotential[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,8] = v.REDISTpotential[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                    v.REDISTregpotential[t,10] = v.REDISTpotential[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

                end
            end

            ###################################################################################################################################
            ################### Third  VERSION  ###############################################################################################
            ###################################################################################################################################


            for r in d.regions
               if v.REDISTregpotential[t,r] > 0
                    v.ABATECOSTforeignpotential[t,r] = v.REDISTregpotential[t,r]
               else
                    v.ABATECOSTforeignpotential[t,r] = 0
               end
               # println("v.ABATECOSTforeignpotential[t,r]", v.ABATECOSTforeignpotential[t,r])
            end



            for r in d.regions
                # v.ABATECOSTtotal[t,r] = v.ABATECOST[t,r] + v.ABATECOSTforeignpotential[t,r]

                v.MIUforeigncalc[t,r] = (v.ABATECOSTforeignpotential[t,r] / (p.YGROSS[t,r] * p.cost1[t,r])) ^ (1/p.expcost2[r])

                if v.MIUforeigncalc[t,r] <= 1
                    v.MIUforeign[t,r] = v.MIUforeigncalc[t,r]
                else
                    v.MIUforeign[t,r] = 1
                end
            end

                # v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
            for r in d.regions
                v.ABATECOSTtotal[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r] + v.MIUforeign[t,r])^p.expcost2[r]
            end

            for r in d.regions
                v.ABATECOSTpotential[t,r] = v.ABATECOSTtotal[t,r] - v.ABATECOSTforeignpotential[t,r]
            end


                    # NEW: COUNTRY-LEVEL: Define function for ABATECOST  - need to CHANGE that (does not take into account foreign abatement yet)
                    for c in d.countries
                        if p.inregion[c] == 1
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,1] * (p.MIU[t,1]^p.expcost2[1]) * (p.partfract[t,1]^(1 - p.expcost2[1]))
                        elseif p.inregion[c] == 2
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,2] * (p.MIU[t,2]^p.expcost2[2]) * (p.partfract[t,2]^(1 - p.expcost2[2]))
                        elseif p.inregion[c] == 3
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,3] * (p.MIU[t,3]^p.expcost2[3]) * (p.partfract[t,3]^(1 - p.expcost2[3]))
                        elseif p.inregion[c] == 4
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,4] * (p.MIU[t,4]^p.expcost2[4]) * (p.partfract[t,4]^(1 - p.expcost2[4]))
                        elseif p.inregion[c] == 5
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,5] * (p.MIU[t,5]^p.expcost2[5]) * (p.partfract[t,5]^(1 - p.expcost2[5]))
                        elseif p.inregion[c] == 6
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,6] * (p.MIU[t,6]^p.expcost2[6]) * (p.partfract[t,6]^(1 - p.expcost2[6]))
                        elseif p.inregion[c] == 7
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,7] * (p.MIU[t,7]^p.expcost2[7]) * (p.partfract[t,7]^(1 - p.expcost2[7]))
                        elseif p.inregion[c] == 8
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,8] * (p.MIU[t,8]^p.expcost2[8]) * (p.partfract[t,8]^(1 - p.expcost2[8]))
                        elseif p.inregion[c] == 9
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,9] * (p.MIU[t,9]^p.expcost2[9]) * (p.partfract[t,9]^(1 - p.expcost2[9]))
                        elseif p.inregion[c] == 10
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,10] * (p.MIU[t,10]^p.expcost2[10]) * (p.partfract[t,10]^(1 - p.expcost2[10]))
                        elseif p.inregion[c] == 11
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,11] * (p.MIU[t,11]^p.expcost2[11]) * (p.partfract[t,11]^(1 - p.expcost2[11]))
                        elseif p.inregion[c] == 12
                            v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,12] * (p.MIU[t,12]^p.expcost2[12]) * (p.partfract[t,12]^(1 - p.expcost2[12]))
                        else
                            println("country does not belong to any region")
                        end
                    end


            for r in d.regions
                v.MIUtotalcalc[t,r] = p.MIU[t,r] + v.MIUforeign[t,r]

                if v.MIUtotalcalc[t,r] <= 1
                    v.MIUtotal[t,r] = v.MIUtotalcalc[t,r]
                else
                    v.MIUtotal[t,r] = 1
                end
            end

            for r in d.regions
                v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUtotal[t,r])
                v.EINDforeign[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUforeign[t,r])
                v.EINDdomestic[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
            end


            for r in d.regions
                #Define function for E
                if p.marginalemission == 0
                    v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
                elseif p.marginalemission == 1
                    if t.t == 2
                        v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
                    else
                        v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
                    end
                else
                    println("no marginal emissions")
                end
            end

            for r in d.regions
                #Define function for CCA
                if is_first(t)
                    v.CCA[t] = sum(v.EIND[t,:]) * 10.
                else
                    v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
                end
            end

            for r in d.regions
                if v.ABATECOSTforeignpotential[t,r] <= v.ABATECOSTtotal[t,r]
                    v.ABATECOSTforeign[t,r] = v.ABATECOSTforeignpotential[t,r]
                else
                    v.ABATECOSTforeign[t,r] = v.ABATECOSTtotal[t,r]
                end

                v.ABATECOST[t,r] = v.ABATECOSTtotal[t,r] - v.ABATECOSTforeign[t,r]
            end


            # Define actual REDISTreg
            for r in d.regions
                v.REDIST[t] = v.ABATECOSTforeign[t,6] + v.ABATECOSTforeign[t,7] + v.ABATECOSTforeign[t,9] + v.ABATECOSTforeign[t,12] + v.ABATECOSTforeign[t,4] + v.ABATECOSTforeign[t,5] + v.ABATECOSTforeign[t,8] + v.ABATECOSTforeign[t,10]

                if t.t == 1
                    v.REDISTreg[t,1] = 0
                    v.REDISTreg[t,2] = 0
                    v.REDISTreg[t,3] = 0
                    v.REDISTreg[t,11] = 0

                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]

                elseif t.t == 2
                    v.REDISTreg[t,1] = - v.REDIST[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,2] = - v.REDIST[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,3] = - v.REDIST[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,11] = - v.REDIST[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]

                else
                    v.REDISTreg[t,1] = - v.REDIST[t] * (p.YNET[t-1,1]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,2] = - v.REDIST[t] * (p.YNET[t-1,2]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,3] = - v.REDIST[t] * (p.YNET[t-1,3]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))
                    v.REDISTreg[t,11] = - v.REDIST[t] * (p.YNET[t-1,11]/(p.YNET[t-1,1] + p.YNET[t-1,2] + p.YNET[t-1,3] + p.YNET[t-1,11]))

                    #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                    v.REDISTreg[t,6] =  v.ABATECOSTforeign[t,6]
                    v.REDISTreg[t,7] = v.ABATECOSTforeign[t,7]
                    v.REDISTreg[t,9] = v.ABATECOSTforeign[t,9]
                    v.REDISTreg[t,12] = v.ABATECOSTforeign[t,12]
                    v.REDISTreg[t,4] = v.ABATECOSTforeign[t,4]
                    v.REDISTreg[t,5] = v.ABATECOSTforeign[t,5]
                    v.REDISTreg[t,8] = v.ABATECOSTforeign[t,8]
                    v.REDISTreg[t,10] = v.ABATECOSTforeign[t,10]
                end
            end


            #Define function for MCABATE
            # OLD
                # for r in d.regions
                #     v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
                # end

            # NEW
            for r in d.regions
                if p.MIU[t,r] == 0
                    v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
                else
                    v.MCABATE[t,r] = p.pbacktime[t,r] * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
                end
            end

            #Define function for CPRICE
            # This I can change to an increasing carbon price
                #OLD
                # for r in d.regions
                #     v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
                # end

            # NEW
            for r in d.regions
                if p.MIU[t,r] == 0
                    v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
                else
                    v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
                end
            end


            # NEW MCABATE for the whole economy (considering foreign and domestic abatement)
            for r in d.regions
                v.MCABATEtotal[t,r] = p.pbacktime[t,r] * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
            end

            # NEW CPRICE for the whole economy (considering foreign and domestic abatement)
            for r in d.regions
                v.CPRICEtotal[t,r] = p.pbacktime[t,r] * 1000 * v.MIUtotal[t,r]^(p.expcost2[r] - 1)
            end


        else
            println("No foreign abatement scenario selected")
        end

    end     # ends function run_timestep
end         # ends emissions component


















# ###################################################################################################################################
# ################### OLD VERSIONS  ###############################################################################################
# ###################################################################################################################################

# ###################################################################################################################################
# ################### SECOND VERSION  ###############################################################################################
# ###################################################################################################################################
#
#
#         for r in d.regions
#            if v.REDISTregpotential[t,r] > 0
#                 v.ABATECOSTforeignpotential[t,r] = v.REDISTregpotential[t,r]
#            else
#                 v.ABATECOSTforeignpotential[t,r] = 0
#            end
#            # println("v.ABATECOSTforeignpotential[t,r]", v.ABATECOSTforeignpotential[t,r])
#         end
#
#
#
#     for r in d.regions
#         # v.ABATECOSTtotal[t,r] = v.ABATECOST[t,r] + v.ABATECOSTforeignpotential[t,r]
#
#         v.MIUforeigncalc[t,r] = (v.ABATECOSTforeignpotential[t,r] / (p.YGROSS[t,r] * p.cost1[t,r])) ^ (1/p.expcost2[r])
#
#         if v.MIUforeigncalc[t,r] <= 1
#             v.MIUforeign[t,r] = v.MIUforeigncalc[t,r]
#         else
#             v.MIUforeign[t,r] = 1
#         end
#
#         # v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
#
#         v.MIUtotalcalc[t,r] = ((v.ABATECOSTforeignpotential[t,r] + v.ABATECOSTpotential[t,r])/ (p.YGROSS[t,r] * p.cost1[t,r])) ^ (1/p.expcost2[r])
#
#                 if v.MIUtotalcalc[t,r] <= 1
#                     v.MIUtotal[t,r] = v.MIUtotalcalc[t,r]
#                 else
#                     v.MIUtotal[t,r] = 1
#                 end
#
#         # v.EINDdomestic[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
#         # v.EINDforeign[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUforeign[t,r])
#         v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUtotal[t,r])
#
#
#
#         #Define function for E
#         if p.marginalemission == 0
#             v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
#         elseif p.marginalemission == 1
#             if t.t == 2
#                 v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
#             else
#                 v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
#             end
#         else
#             println("no marginal emissions")
#         end
#
#         #Define function for CCA
#         if is_first(t)
#             v.CCA[t] = sum(v.EIND[t,:]) * 10.
#         else
#             v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
#         end
#
#     end
#
#



###################################################################################################################################
################### FIST VERSION (probably wrong, but model does run) #############################################################
###################################################################################################################################
#
#         for r in d.regions
#            if v.REDISTregpotential[t,r] > 0
#                 v.ABATECOSTforeignpotential[t,r] = v.REDISTregpotential[t,r]
#            else
#                 v.ABATECOSTforeignpotential[t,r] = 0
#            end
#            # println("v.ABATECOSTforeignpotential[t,r]", v.ABATECOSTforeignpotential[t,r])
#         end
#
#
#
#     for r in d.regions
#         v.ABATECOSTtotal[t,r] = v.ABATECOSTpotential[t,r] + v.ABATECOSTforeignpotential[t,r]
#
#         v.MIUtotalcalc[t,r] = (v.ABATECOSTtotal[t,r] / (p.YGROSS[t,r] * p.cost1[t,r])) ^ (1/p.expcost2[r])
#
#         if v.MIUtotalcalc[t,r] <= 1
#             v.MIUtotal[t,r] = v.MIUtotalcalc[t,r]
#         else
#             v.MIUtotal[t,r] = 1
#         end
#
#         v.MIUforeign[t,r] = v.MIUtotal[t,r] - p.MIU[t,r]
#
#         v.EINDdomestic[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
#         v.EINDforeign[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUforeign[t,r])
#         v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-v.MIUtotal[t,r])
#
#
#
#         #Define function for E
#         if p.marginalemission == 0
#             v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
#         elseif p.marginalemission == 1
#             if t.t == 2
#                 v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
#             else
#                 v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
#             end
#         else
#             println("no marginal emissions")
#         end
#
#         #Define function for CCA
#         if is_first(t)
#             v.CCA[t] = sum(v.EIND[t,:]) * 10.
#         else
#             v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
#         end
#
#     end









        # for r in d.regions
        #      if t.t == 1
        #          v.ABATECOSTforeignpotential[t,r] = 0
        #     else
        #     # if p.REDISTreg[t,r] > 0
        #         v.ABATECOSTforeignpotential[t,r] = p.REDISTreg[t-1,r]
        #     # else
        #     #     v.ABATECOSTforeignpotential[t,r] = 0
        #     # end
        #     end
        # end
