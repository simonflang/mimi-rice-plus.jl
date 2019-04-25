using Mimi

@defcomp damages begin
    regions = Index()

    DAMFRAC = Variable(index=[time, regions]) # Damages as % of GDP
    DAMAGES = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    # Simon's changes
    TATMABS = Variable(index=[time, regions]) # Regional Absolute Temperature (1900 temperature + TATM)

    TATM = Parameter(index=[time]) # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    SLRDAMAGES = Parameter(index=[time, regions])
    a1 = Parameter(index=[regions]) # Damage intercept
    a2 = Parameter(index=[regions]) # Damage quadratic term
    a3 = Parameter(index=[regions]) # Damage exponent
    d1 = Parameter() # BHM Economic Impact Function intercept
    d2 = Parameter() # BHM Economic Impact Function quadratic term

    # Simon's changes
    tatm1900 = Parameter(index=[regions]) # Regional Temperature in 1900

    function run_timestep(p, v, d, t)

    # Simon's changes

    #Define function for DAMFRAC
    for r in d.regions
        v.DAMFRAC[t,r] = ((p.d1 * v.TATMABS[t,r] + p.d2 * v.TATMABS[t,r]^2) - (p.d1 * p.tatm1900[r] + p.d2 * p.tatm1900[r]^2)) + (p.SLRDAMAGES[t,r] / 100)
    end

        # OLD - Define function for DAMFRAC
        # for r in d.regions
            # v.DAMFRAC[t,r] = (((p.a1[r] * p.TATM[t]) + (p.a2[r] * p.TATM[t]^p.a3[r])) / 100) + (p.SLRDAMAGES[t,r] / 100)
        # end

        #Define function for DAMAGES
        for r in d.regions
            if is_first(t)
                v.DAMAGES[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRAC[t,r]))
            else
                v.DAMAGES[t,r] = (p.YGROSS[t,r] * v.DAMFRAC[t,r]) / (1. + v.DAMFRAC[t,r]^10)
            end
        end
    end
end
