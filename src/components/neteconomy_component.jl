using Mimi

global damagefunction = "Original"         # "Burke" (default), "Original"
global redistribution = "H4-L8-GDP"        # "US-Afr", "H4-L4", "H4-L8", "H4-Afr", "H4-L8-GDP"

@defcomp neteconomy begin
    regions = Index()
    countries = Index() # NEW: COUNTRY-LEVEL

    YNET = Variable(index=[time, regions]) # Output net of damages equation (trillions 2005 USD per year)
    Y = Variable(index=[time, regions]) # Gross world product net of abatement and damages (trillions 2005 USD per year)
    I = Variable(index=[time, regions]) # Investment (trillions 2005 USD per year)
    C = Variable(index=[time, regions]) # Consumption (trillions 2005 US dollars per year)
    CPC = Variable(index=[time, regions]) # Per capita consumption (thousands 2005 USD per year)

    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    DAMFRAC = Parameter(index=[time, regions]) # Damages as fraction of gross output
    DAMAGES = Parameter(index=[time, regions]) # Damages (trillions 2005 USD per year)
    ABATECOST = Parameter(index=[time, regions]) # Cost of emissions reductions  (trillions 2005 USD per year)
    S = Parameter(index=[time, regions]) # Gross savings rate as fraction of gross world product
    l = Parameter(index=[time, regions]) # Level of population and labor

                # NEW: COUNTRY-LEVEL
                YNETctry = Variable(index=[time, countries]) # Output net of damages equation (trillions 2005 USD per year)
                Yctry = Variable(index=[time, countries]) # Output net of damages equation (trillions 2005 USD per year)
                Ictry = Variable(index=[time, countries]) # Investment (trillions 2005 USD per year)
                Cctry = Variable(index=[time, countries]) # Consumption (trillions 2005 US dollars per year)
                lctry = Variable(index=[time, countries]) # Level of population and labor
                CPCctry = Variable(index=[time, countries]) # Per capita consumption (thousands 2005 USD per year)

                inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to
                popshare = Parameter(index=[countries])  # population share of a country within the region

                YGROSSctry = Parameter(index=[time, countries]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
                DAMFRACCTRY = Parameter(index=[time, countries]) # Damages as fraction of gross output
                DAMAGESCTRY = Parameter(index=[time, countries]) # Damages (trillions 2005 USD per year)
                ABATECOSTctry = Parameter(index=[time, countries]) # Cost of emissions reductions  (trillions 2005 USD per year)

                # NEW: REGION-LEVEL
                Ictryagg = Variable(index=[time, regions]) # Investment (trillions 2005 USD per year)

                # OLD: REGION-LEVEL
                S = Parameter(index=[time, regions]) # Gross savings rate as fraction of gross world product
                l = Parameter(index=[time, regions]) # Level of population and labor

                DAMFRACOLD = Parameter(index=[time, regions]) # Damages as fraction of gross output (calculated via Original RICE damage function)
                DAMAGESOLD = Parameter(index=[time, regions]) # Damages (trillions 2005 USD per year) (calculated via Original RICE damage function)

                # NEW: Consumption in 2015 (for SCC caclualtion)
                C2015 = Variable(index=[regions]) # Consumption (trillions 2005 US dollars per year)

                # NEW: Marginal consumption for SCC calculation
                marginalconsumption = Parameter() # "1" if there is an additional marginal consumption pulse, "0" otherwise

                # NEW: Redistribution
                REDISTbase = Parameter(index=[time]) # Redistribution in the base year (trillions 2005 USD per year) - for some redistribution schemes, the actual redistribution quantity grows relative to the base quantity
                REDIST = Variable(index=[time]) # Actual redistribution (trillions 2005 USD per year)
                REDISTreg = Variable(index=[time, regions]) # Regional Redistribution (trillions 2005 USD per year)
                REDISTregperYNET = Variable(index=[time, regions]) # Regional Redistribution per regional YNET (fraction)
                REDISTregperYNETpr = Variable(index=[time, regions]) # Regional Redistribution per regional YNETpr (fraction)
                YNETpr = Variable(index=[time, regions]) # YNET post redistribution (trillions 2005 USD per year)

    function run_timestep(p, v, d, t)

        #Define function for YNET
        for r in d.regions
            if damagefunction == "Burke"
                if is_first(t)
                    v.YNET[t,r] = p.YGROSS[t,r]/(1+p.DAMFRAC[t,r])
                else
                    v.YNET[t,r] = p.YGROSS[t,r] - p.DAMAGES[t,r]
                end
            elseif damagefunction == "Original"
                if is_first(t)
                    v.YNET[t,r] = p.YGROSS[t,r]/(1+p.DAMFRACOLD[t,r])
                else
                    v.YNET[t,r] = p.YGROSS[t,r] - p.DAMAGESOLD[t,r]
                end
            else
                println("Damage function not correctly specified")
            end
        end

for r in d.regions

        if redistribution == "US-Afr"
            # Redistribution from US to Africa (10 trillion)
            v.YNETpr[t,1] = v.YNET[t,1] - p.REDISTbase[t]
            v.YNETpr[t,9] = v.YNET[t,9] + p.REDISTbase[t]

            v.REDIST[t] = p.REDISTbase[t]

        elseif redistribution == "H4-L4"
            #Donors (US, EU, Japan, OHI)
            v.REDISTreg[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

            v.REDIST[t] = v.REDISTreg[t,1] + v.REDISTreg[t,2] + v.REDISTreg[t,3] + v.REDISTreg[t,11]

            #Recipients (China, India, Africa, OthAsia)
            v.REDISTreg[t,6] = v.REDIST[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12]))
            v.REDISTreg[t,7] = v.REDIST[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12]))
            v.REDISTreg[t,9] = v.REDIST[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12]))
            v.REDISTreg[t,12] = v.REDIST[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12]))

            # Not Donor nor recipient (Russia, Eurasia, MidEast, LatAm)
            v.REDISTreg[t,4] = 0
            v.REDISTreg[t,5] = 0
            v.REDISTreg[t,8] = 0
            v.REDISTreg[t,10] = 0

            v.REDISTregperYNET[t,r] = v.REDISTreg[t,r] / v.YNET[t,r]

            # YNET after Redistribution
            v.YNETpr[t,1] = v.YNET[t,1] + v.REDISTreg[t,1]
            v.YNETpr[t,2] = v.YNET[t,2] + v.REDISTreg[t,2]
            v.YNETpr[t,3] = v.YNET[t,3] + v.REDISTreg[t,3]
            v.YNETpr[t,11] = v.YNET[t,11] + v.REDISTreg[t,11]

            v.YNETpr[t,6] = v.YNET[t,6] + v.REDISTreg[t,6]
            v.YNETpr[t,7] = v.YNET[t,7] + v.REDISTreg[t,7]
            v.YNETpr[t,9] = v.YNET[t,9] + v.REDISTreg[t,9]
            v.YNETpr[t,12] = v.YNET[t,12] + v.REDISTreg[t,12]

            v.YNETpr[t,4] = v.YNET[t,4] + v.REDISTreg[t,4]
            v.YNETpr[t,5] = v.YNET[t,5] + v.REDISTreg[t,5]
            v.YNETpr[t,8] = v.YNET[t,8] + v.REDISTreg[t,8]
            v.YNETpr[t,10] = v.YNET[t,10] + v.REDISTreg[t,10]

        elseif redistribution == "H4-L8"
            #Donors (US, EU, Japan, OHI)
            v.REDISTreg[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

            v.REDIST[t] = v.REDISTreg[t,1] + v.REDISTreg[t,2] + v.REDISTreg[t,3] + v.REDISTreg[t,11]

            #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
            v.REDISTreg[t,6] = v.REDIST[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,7] = v.REDIST[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,9] = v.REDIST[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,12] = v.REDIST[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,4] = v.REDIST[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,5] = v.REDIST[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,8] = v.REDIST[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            v.REDISTreg[t,10] = v.REDIST[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))

            v.REDISTregperYNET[t,r] = v.REDISTreg[t,r] / v.YNET[t,r]

            # YNET after Redistribution
            v.YNETpr[t,1] = v.YNET[t,1] + v.REDISTreg[t,1]
            v.YNETpr[t,2] = v.YNET[t,2] + v.REDISTreg[t,2]
            v.YNETpr[t,3] = v.YNET[t,3] + v.REDISTreg[t,3]
            v.YNETpr[t,11] = v.YNET[t,11] + v.REDISTreg[t,11]

            v.YNETpr[t,6] = v.YNET[t,6] + v.REDISTreg[t,6]
            v.YNETpr[t,7] = v.YNET[t,7] + v.REDISTreg[t,7]
            v.YNETpr[t,9] = v.YNET[t,9] + v.REDISTreg[t,9]
            v.YNETpr[t,12] = v.YNET[t,12] + v.REDISTreg[t,12]

            v.YNETpr[t,4] = v.YNET[t,4] + v.REDISTreg[t,4]
            v.YNETpr[t,5] = v.YNET[t,5] + v.REDISTreg[t,5]
            v.YNETpr[t,8] = v.YNET[t,8] + v.REDISTreg[t,8]
            v.YNETpr[t,10] = v.YNET[t,10] + v.REDISTreg[t,10]

        elseif redistribution == "H4-Afr"
            #Donors (US, EU, Japan, OHI)
            v.REDISTreg[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
            v.REDISTreg[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

            v.REDIST[t] = v.REDISTreg[t,1] + v.REDISTreg[t,2] + v.REDISTreg[t,3] + v.REDISTreg[t,11]

            v.REDISTregperYNET[t,r] = v.REDISTreg[t,r] / v.YNET[t,r]

            # YNET after Redistribution
            v.YNETpr[t,1] = v.YNET[t,1] + v.REDISTreg[t,1]
            v.YNETpr[t,2] = v.YNET[t,2] + v.REDISTreg[t,2]
            v.YNETpr[t,3] = v.YNET[t,3] + v.REDISTreg[t,3]
            v.YNETpr[t,11] = v.YNET[t,11] + v.REDISTreg[t,11]

            v.YNETpr[t,9] = v.YNET[t,9] + v.REDIST[t]

        elseif redistribution == "H4-L8-GDP"
            #Donors (US, EU, Japan, OHI); note that in the last term t=3 (2025) indicates that "developed countries intend to continue their existing collective mobilization goal [of USD 100 billion/year] through 2025" (UNFCCC, 2020)
            if t.t <= 2
                v.REDISTreg[t,1] = - p.REDISTbase[t] * (v.YNET[t,1]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                v.REDISTreg[t,2] = - p.REDISTbase[t] * (v.YNET[t,2]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                v.REDISTreg[t,3] = - p.REDISTbase[t] * (v.YNET[t,3]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))
                v.REDISTreg[t,11] = - p.REDISTbase[t] * (v.YNET[t,11]/(v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]))

                v.REDIST[t] = p.REDISTbase[t]

                #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                v.REDISTreg[t,6] = v.REDIST[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,7] = v.REDIST[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,9] = v.REDIST[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,12] = v.REDIST[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,4] = v.REDIST[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,5] = v.REDIST[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,8] = v.REDIST[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,10] = v.REDIST[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            else
                v.REDISTreg[t,1] = - p.REDISTbase[t] * (v.YNET[3,1]/(v.YNET[3,1] + v.YNET[3,2] + v.YNET[3,3] + v.YNET[3,11])) * (v.YNET[t,1]/v.YNET[3,1])
                v.REDISTreg[t,2] = - p.REDISTbase[t] * (v.YNET[3,2]/(v.YNET[3,1] + v.YNET[3,2] + v.YNET[3,3] + v.YNET[3,11])) * (v.YNET[t,2]/v.YNET[3,2])
                v.REDISTreg[t,3] = - p.REDISTbase[t] * (v.YNET[3,3]/(v.YNET[3,1] + v.YNET[3,2] + v.YNET[3,3] + v.YNET[3,11])) * (v.YNET[t,3]/v.YNET[3,3])
                v.REDISTreg[t,11] = - p.REDISTbase[t] * (v.YNET[3,11]/(v.YNET[3,1] + v.YNET[3,2] + v.YNET[3,3] + v.YNET[3,11])) * (v.YNET[t,11]/v.YNET[3,11])

                v.REDIST[t] = p.REDISTbase[t] * (v.YNET[t,1] + v.YNET[t,2] + v.YNET[t,3] + v.YNET[t,11]) / (v.YNET[3,1] + v.YNET[3,2] + v.YNET[3,3] + v.YNET[3,11])

                #Recipients (China, India, Africa, OthAsia, Russia, Eurasia, MidEast, LatAm)
                v.REDISTreg[t,6] = v.REDIST[t] * (p.l[t,6]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,7] = v.REDIST[t] * (p.l[t,7]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,9] = v.REDIST[t] * (p.l[t,9]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,12] = v.REDIST[t] * (p.l[t,12]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,4] = v.REDIST[t] * (p.l[t,4]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,5] = v.REDIST[t] * (p.l[t,5]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,8] = v.REDIST[t] * (p.l[t,8]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
                v.REDISTreg[t,10] = v.REDIST[t] * (p.l[t,10]/(p.l[t,6] + p.l[t,7] + p.l[t,9] + p.l[t,12] + p.l[t,4] + p.l[t,5] + p.l[t,8] + p.l[t,10]))
            end

                # YNET after Redistribution (pr = post redistribution)
                v.YNETpr[t,1] = v.YNET[t,1] + v.REDISTreg[t,1]
                v.YNETpr[t,2] = v.YNET[t,2] + v.REDISTreg[t,2]
                v.YNETpr[t,3] = v.YNET[t,3] + v.REDISTreg[t,3]
                v.YNETpr[t,11] = v.YNET[t,11] + v.REDISTreg[t,11]

                v.YNETpr[t,6] = v.YNET[t,6] + v.REDISTreg[t,6]
                v.YNETpr[t,7] = v.YNET[t,7] + v.REDISTreg[t,7]
                v.YNETpr[t,9] = v.YNET[t,9] + v.REDISTreg[t,9]
                v.YNETpr[t,12] = v.YNET[t,12] + v.REDISTreg[t,12]

                v.YNETpr[t,4] = v.YNET[t,4] + v.REDISTreg[t,4]
                v.YNETpr[t,5] = v.YNET[t,5] + v.REDISTreg[t,5]
                v.YNETpr[t,8] = v.YNET[t,8] + v.REDISTreg[t,8]
                v.YNETpr[t,10] = v.YNET[t,10] + v.REDISTreg[t,10]

                v.REDISTregperYNET[t,r] = v.REDISTreg[t,r] / v.YNET[t,r]
                v.REDISTregperYNETpr[t,r] = v.REDISTreg[t,r] / v.YNETpr[t,r]
        else
            println("Redistribution not correctly specified")
        end

end


                    # NEW: COUNTRY-LEVEL - Define function for YNET
                    for c in d.countries
                        if is_first(t)
                            v.YNETctry[t,c] = p.YGROSSctry[t,c]/(1+p.DAMFRACCTRY[t,c])
                        else
                            v.YNETctry[t,c] = p.YGROSSctry[t,c] - p.DAMAGESCTRY[t,c]
                        end
                    end

        #Define function for Y
        for r in d.regions
            v.Y[t,r] = v.YNETpr[t,r] - p.ABATECOST[t,r]
        end

                    # NEW: COUNTRY-LEVEL - Define function for Y
                    for c in d.countries
                        v.Yctry[t,c] = v.YNETctry[t,c] - p.ABATECOSTctry[t,c]   # note: no country-level YNETpr implemented yet
                    end

        #Define function for I
        for r in d.regions
            v.I[t,r] = p.S[t,r] * v.Y[t,r]
        end

                    # NEW: COUNTRY-LEVEL - Define function for I
                    for c in d.countries
                        if p.inregion[c] == 1
                            v.Ictry[t,c] = p.S[t,1] * v.Yctry[t,c]
                        elseif p.inregion[c] == 2
                            v.Ictry[t,c] = p.S[t,2] * v.Yctry[t,c]
                        elseif p.inregion[c] == 3
                            v.Ictry[t,c] = p.S[t,3] * v.Yctry[t,c]
                        elseif p.inregion[c] == 4
                            v.Ictry[t,c] = p.S[t,4] * v.Yctry[t,c]
                        elseif p.inregion[c] == 5
                            v.Ictry[t,c] = p.S[t,5] * v.Yctry[t,c]
                        elseif p.inregion[c] == 6
                            v.Ictry[t,c] = p.S[t,6] * v.Yctry[t,c]
                        elseif p.inregion[c] == 7
                            v.Ictry[t,c] = p.S[t,7] * v.Yctry[t,c]
                        elseif p.inregion[c] == 8
                            v.Ictry[t,c] = p.S[t,8] * v.Yctry[t,c]
                        elseif p.inregion[c] == 9
                            v.Ictry[t,c] = p.S[t,9] * v.Yctry[t,c]
                        elseif p.inregion[c] == 10
                            v.Ictry[t,c] = p.S[t,10] * v.Yctry[t,c]
                        elseif p.inregion[c] == 11
                            v.Ictry[t,c] = p.S[t,11] * v.Yctry[t,c]
                        elseif p.inregion[c] == 12
                            v.Ictry[t,c] = p.S[t,12] * v.Yctry[t,c]
                        else
                            println("country does not belong to any region")
                        end
                    end


                ### Aggregate country-level investment to the region-level investment

                    # set initial value of Ictryagg to 0
                    v.Ictryagg[t,1] = 0
                    v.Ictryagg[t,2] = 0
                    v.Ictryagg[t,3] = 0
                    v.Ictryagg[t,4] = 0
                    v.Ictryagg[t,5] = 0
                    v.Ictryagg[t,6] = 0
                    v.Ictryagg[t,7] = 0
                    v.Ictryagg[t,8] = 0
                    v.Ictryagg[t,9] = 0
                    v.Ictryagg[t,10] = 0
                    v.Ictryagg[t,11] = 0
                    v.Ictryagg[t,12] = 0

                    for c in d.countries
                        if p.inregion[c] == 1
                            global v.Ictryagg[t,1] = v.Ictryagg[t,1] + v.Ictry[t,c]
                        elseif p.inregion[c] == 2
                            global v.Ictryagg[t,2] = v.Ictryagg[t,2] + v.Ictry[t,c]
                        elseif p.inregion[c] == 3
                            global v.Ictryagg[t,3] = v.Ictryagg[t,3] + v.Ictry[t,c]
                        elseif p.inregion[c] == 4
                            global v.Ictryagg[t,4] = v.Ictryagg[t,4] + v.Ictry[t,c]
                        elseif p.inregion[c] == 5
                            global v.Ictryagg[t,5] = v.Ictryagg[t,5] + v.Ictry[t,c]
                        elseif p.inregion[c] == 6
                            global v.Ictryagg[t,6] = v.Ictryagg[t,6] + v.Ictry[t,c]
                        elseif p.inregion[c] == 7
                            global v.Ictryagg[t,7] = v.Ictryagg[t,7] + v.Ictry[t,c]
                        elseif p.inregion[c] == 8
                            global v.Ictryagg[t,8] = v.Ictryagg[t,8] + v.Ictry[t,c]
                        elseif p.inregion[c] == 9
                            global v.Ictryagg[t,9] = v.Ictryagg[t,9] + v.Ictry[t,c]
                        elseif p.inregion[c] == 10
                            global v.Ictryagg[t,10] = v.Ictryagg[t,10] + v.Ictry[t,c]
                        elseif p.inregion[c] == 11
                            global v.Ictryagg[t,11] = v.Ictryagg[t,11] + v.Ictry[t,c]
                        elseif p.inregion[c] == 12
                            global v.Ictryagg[t,12] = v.Ictryagg[t,12] + v.Ictry[t,c]
                        else
                            println("country does not belong to any region")
                        end
                    end

        # #Define function for C
        # for r in d.regions
        #     if t.t != 60
        #         v.C[t,r] = v.Y[t,r] - v.I[t,r]
        #     else
        #         v.C[t,r] = v.C[t-1, r]
        #     end
        # end

        for r in d.regions
            if p.marginalconsumption == 0
                if t.t != 60
                    v.C[t,r] = v.Y[t,r] - v.I[t,r]
                else
                    v.C[t,r] = v.C[t-1, r]
                end
            elseif p.marginalconsumption == 1
                if t.t != 60
                    if t.t == 2
                        v.C[t,r] = v.Y[t,r] - v.I[t,r] + 10^(-6)  # consumption pulse of 1 million $ (10^(-6) to get from trillions to millions)
                    else
                        v.C[t,r] = v.Y[t,r] - v.I[t,r]
                    end
                else
                    v.C[t,r] = v.C[t-1, r]
                end
            else
                println("marginal consumption not correctly defined")
            end
        end

        # Consumption in 2015 (for SCC calculation)
        if t.t == 2
            for r in d.regions
                v.C2015[r] = v.C[t,r]
            end
        end


                    # NEW: COUNTRY-LEVEL - Define function for C
                    for c in d.countries
                        if t.t != 60
                            v.Cctry[t,c] = v.Yctry[t,c] - v.Ictry[t,c]
                        else
                            v.Cctry[t,c] = v.Cctry[t-1, c]
                        end
                    end

        #Define function for CPC
        for r in d.regions
            v.CPC[t,r] = 1000 * v.C[t,r] / p.l[t,r]
        end

                    # NEW: COUNTRY-LEVEL - Define function for country-level population lctry
                    for c in d.countries
                        if p.inregion[c] == 1
                            v.lctry[t,c] = p.l[t,1] * p.popshare[c]
                        elseif p.inregion[c] == 2
                            v.lctry[t,c] = p.l[t,2] * p.popshare[c]
                        elseif p.inregion[c] == 3
                            v.lctry[t,c] = p.l[t,3] * p.popshare[c]
                        elseif p.inregion[c] == 4
                            v.lctry[t,c] = p.l[t,4] * p.popshare[c]
                        elseif p.inregion[c] == 5
                            v.lctry[t,c] = p.l[t,5] * p.popshare[c]
                        elseif p.inregion[c] == 6
                            v.lctry[t,c] = p.l[t,6] * p.popshare[c]
                        elseif p.inregion[c] == 7
                            v.lctry[t,c] = p.l[t,7] * p.popshare[c]
                        elseif p.inregion[c] == 8
                            v.lctry[t,c] = p.l[t,8] * p.popshare[c]
                        elseif p.inregion[c] == 9
                            v.lctry[t,c] = p.l[t,9] * p.popshare[c]
                        elseif p.inregion[c] == 10
                            v.lctry[t,c] = p.l[t,10] * p.popshare[c]
                        elseif p.inregion[c] == 11
                            v.lctry[t,c] = p.l[t,11] * p.popshare[c]
                        elseif p.inregion[c] == 12
                            v.lctry[t,c] = p.l[t,12] * p.popshare[c]
                        else
                            println("country does not belong to any region")
                        end
                    end

                    # NEW: COUNTRY-LEVEL - Define function for CPC
                    for c in d.countries
                        # println(c)
                        v.CPCctry[t,c] = 1000 * v.Cctry[t,c] / v.lctry[t,c]
                        # println(v.CPCctry[t,c])
                    end

    end
end
