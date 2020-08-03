module Rice2010

using Mimi

include("parameters.jl")
# include("marginaldamage.jl") that's not working -->  do not include

include("components/climatedynamics_component.jl")
include("components/co2cycle_component.jl")
include("components/damages_component.jl")
include("components/emissions_component.jl")
include("components/grosseconomy_component.jl")
include("components/neteconomy_component.jl")
include("components/radiativeforcing_component.jl")
include("components/slr_component.jl")
include("components/slrdamages_component.jl")
include("components/welfare_component.jl")

export constructrice, getrice, getrice2010parameters

function constructrice(p)

    m = Model()
    set_dimension!(m, :time, 2005:10:2595)
    set_dimension!(m, :regions, ["US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAsia"])

    # NEW: COUNTRY-LEVEL - set dimensions for countries
    set_dimension!(m, :countries, ["AFG",	"AGO",	"ALB",	"ARE",	"ARG",	"ARM",	"AUS",	"AUT",	"AZE",	"BDI",	"BEL",	"BEN",	"BFA",	"BGD",	"BGR",	"BHR",	"BHS",	"BIH",	"BLR",	"BLZ",	"BOL",	"BRA",	"BRB",	"BRN",	"BTN",	"BWA",	"CAF",	"CAN",	"CHE",	"CHL",	"CHN",	"CIV",	"CMR",	"COD",	"COG",	"COL",	"COM",	"CPV",	"CRI",	"CUB",	"CYP",	"CZE",	"DEU",	"DJI",	"DNK",	"DOM",	"DZA",	"ECU",	"EGY",	"ERI",	"ESP",	"EST",	"ETH",	"FIN",	"FJI",	"FRA",	"GAB",	"GBR",	"GEO",	"GHA",	"GIN",	"GMB",	"GNB",	"GNQ",	"GRC",	"GRD",	"GTM",	"GUM",	"GUY",	"HKG",	"HND",	"HRV",	"HTI",	"HUN",	"IDN",	"IND",	"IRL",	"IRN",	"IRQ",	"ISL",	"ISR",	"ITA",	"JAM",	"JOR",	"JPN",	"KAZ",	"KEN",	"KGZ",	"KHM",	"KOR",	"KWT",	"LAO",	"LBN",	"LBR",	"LBY",	"LCA",	"LKA",	"LSO",	"LTU",	"LUX",	"LVA",	"MAR",	"MDA",	"MDG",	"MEX",	"MKD",	"MLI",	"MMR",	"MNE",	"MNG",	"MOZ",	"MRT",	"MUS",	"MWI",	"MYS",	"NAM",	"NCL",	"NER",	"NGA",	"NIC",	"NLD",	"NOR",	"NPL",	"NZL",	"OMN",	"PAK",	"PAN",	"PER",	"PHL",	"PNG",	"POL",	"PRI",	"PRK",	"PRT",	"PRY",	"PSE",	"QAT",	"ROU",	"RUS",	"RWA",	"SAU",	"SDN",	"SEN",	"SLB",	"SLE",	"SLV",	"SOM",	"SRB",	"STP",	"SUR",	"SVK",	"SVN",	"SWE",	"SWZ",	"SYR",	"TCD",	"TGO",	"THA",	"TJK",	"TKM",	"TLS",	"TON",	"TTO",	"TUN",	"TUR",	"TZA",	"UGA",	"UKR",	"URY",	"USA",	"UZB",	"VCT",	"VEN",	"VIR",	"VNM",	"VUT",	"WSM",	"YEM",	"ZAF",	"ZMB",	"ZWE"])

    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, emissions, :emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, radiativeforcing, :radiativeforcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, sealevelrise, :sealevelrise)
    add_comp!(m, sealeveldamages, :sealeveldamages)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    # GROSS ECONOMY COMPONENT
    set_param!(m, :grosseconomy, :al, p[:al])
    set_param!(m, :grosseconomy, :l, p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk, p[:dk])
    set_param!(m, :grosseconomy, :k0, p[:k0])

        # NEW: COUNTRY-LEVEL - GDP share
    set_param!(m, :grosseconomy, :gdpshare, p[:gdpshare])
    set_param!(m, :grosseconomy, :inregion, p[:inregion])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

        # NEW: REGION-LEVEL - INVESTMENT
    connect_param!(m, :grosseconomy, :Ictryagg, :neteconomy, :Ictryagg)

    # EMISSIONS COMPONENT
    set_param!(m, :emissions, :sigma, p[:sigma])
    set_param!(m, :emissions, :MIU, p[:MIU])
    set_param!(m, :emissions, :etree, p[:etree])
    set_param!(m, :emissions, :cost1, p[:cost1])
    set_param!(m, :emissions, :MIU, p[:MIU])
    set_param!(m, :emissions, :expcost2, p[:expcost2])
    set_param!(m, :emissions, :partfract, p[:partfract])
    set_param!(m, :emissions, :pbacktime, p[:pbacktime])

    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

        # NEW: Foreign Abatement
        # connect_param!(m, :emissions, :REDIST, :neteconomy, :REDISTreg)
        set_param!(m, :emissions, :l, p[:l])
        set_param!(m, :emissions, :REDISTbase, p[:REDISTbase])
        set_param!(m, :emissions, :MIUtotal, p[:MIUtotal])

        connect_param!(m, :emissions, :YNET, :neteconomy, :YNET)

    # NEW: COUNTRY-LEVEL - YGROSSctry
    connect_param!(m, :emissions, :YGROSSctry, :grosseconomy, :YGROSSctry)
    set_param!(m, :emissions, :inregion, p[:inregion])

    # CO2 CYCLE COMPONENT
    set_param!(m, :co2cycle, :mat0, p[:mat0])
    set_param!(m, :co2cycle, :mat1, p[:mat1])
    set_param!(m, :co2cycle, :mu0, p[:mu0])
    set_param!(m, :co2cycle, :ml0, p[:ml0])
    set_param!(m, :co2cycle, :b12, p[:b12])
    set_param!(m, :co2cycle, :b23, p[:b23])
    set_param!(m, :co2cycle, :b11, p[:b11])
    set_param!(m, :co2cycle, :b21, p[:b21])
    set_param!(m, :co2cycle, :b22, p[:b22])
    set_param!(m, :co2cycle, :b32, p[:b32])
    set_param!(m, :co2cycle, :b33, p[:b33])

    connect_param!(m, :co2cycle, :E, :emissions, :E)

    # RADIATIVE FORCING COMPONENT
    set_param!(m, :radiativeforcing, :forcoth, p[:forcoth])
    set_param!(m, :radiativeforcing, :fco22x, p[:fco22x])
    set_param!(m, :radiativeforcing, :mat1, p[:mat1])

    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MATSUM, :co2cycle, :MATSUM)

    # CLIMATE DYNAMICS COMPONENT
    set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(m, :climatedynamics, :tatm1, p[:tatm1])
    set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(m, :climatedynamics, :c1, p[:c1])
    set_param!(m, :climatedynamics, :c3, p[:c3])
    set_param!(m, :climatedynamics, :c4, p[:c4])

    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # SEA LEVEL RISE COMPONENT
    set_param!(m, :sealevelrise, :thermeq, p[:thermeq])
    set_param!(m, :sealevelrise, :therm0, p[:therm0])
    set_param!(m, :sealevelrise, :thermadj, p[:thermadj])
    set_param!(m, :sealevelrise, :gsictotal, p[:gsictotal])
    set_param!(m, :sealevelrise, :gsicmelt, p[:gsicmelt])
    set_param!(m, :sealevelrise, :gsicexp, p[:gsicexp])
    set_param!(m, :sealevelrise, :gis0, p[:gis0])
    set_param!(m, :sealevelrise, :gismelt0, p[:gismelt0])
    set_param!(m, :sealevelrise, :gismeltabove, p[:gismeltabove])
    set_param!(m, :sealevelrise, :gismineq, p[:gismineq])
    set_param!(m, :sealevelrise, :gisexp, p[:gisexp])
    set_param!(m, :sealevelrise, :aismelt0, p[:aismelt0])
    set_param!(m, :sealevelrise, :aismeltlow, p[:aismeltlow])
    set_param!(m, :sealevelrise, :aismeltup, p[:aismeltup])
    set_param!(m, :sealevelrise, :aisratio, p[:aisratio])
    set_param!(m, :sealevelrise, :aisinflection, p[:aisinflection])
    set_param!(m, :sealevelrise, :aisintercept, p[:aisintercept])
    set_param!(m, :sealevelrise, :aiswais, p[:aiswais])
    set_param!(m, :sealevelrise, :aisother, p[:aisother])

    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)

    set_param!(m, :sealeveldamages, :slrmultiplier, p[:slrmultiplier])
    set_param!(m, :sealeveldamages, :slrelasticity, p[:slrelasticity])
    set_param!(m, :sealeveldamages, :slrdamlinear, p[:slrdamlinear])
    set_param!(m, :sealeveldamages, :slrdamquadratic, p[:slrdamquadratic])

    connect_param!(m, :sealeveldamages, :TOTALSLR, :sealevelrise, :TOTALSLR)
    connect_param!(m, :sealeveldamages, :YGROSS, :grosseconomy, :YGROSS)

    # DAMAGES COMPONENT
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])

        # NEW: REGION-LEVEL - damage coefficients
    set_param!(m, :damages, :f1, p[:f1])
    set_param!(m, :damages, :f2, p[:f2])
    set_param!(m, :damages, :f3, p[:f3])

        # NEW: COUNTRY-LEVEL - damage coefficients
    set_param!(m, :damages, :n1, p[:n1])
    set_param!(m, :damages, :n2, p[:n2])
    set_param!(m, :damages, :n3, p[:n3])


        # NEW: COUNTRY-LEVEL - coastal population share to determine SLR damages share
    set_param!(m, :damages, :coastalpopshare, p[:coastalpopshare])
    set_param!(m, :damages, :inregion, p[:inregion])
    set_param!(m, :damages, :gdpshare, p[:gdpshare])

    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :SLRDAMAGES, :sealeveldamages, :SLRDAMAGES)

        # NEW: COUNTRY-LEVEL - YGROSSctry
    connect_param!(m, :damages, :YGROSSctry, :grosseconomy, :YGROSSctry)

    # NET ECONOMY COMPONENT
    set_param!(m, :neteconomy, :S, p[:savings])
    set_param!(m, :neteconomy, :l, p[:l])

    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
    connect_param!(m, :neteconomy, :ABATECOST, :emissions, :ABATECOST)

            # NEW: COUNTRY-LEVEL - YGROSSctry
            set_param!(m, :neteconomy, :inregion, p[:inregion])
            set_param!(m, :neteconomy, :popshare, p[:popshare])

            connect_param!(m, :neteconomy, :YGROSSctry, :grosseconomy, :YGROSSctry)
            connect_param!(m, :neteconomy, :DAMFRACCTRY, :damages, :DAMFRACCTRY)
            connect_param!(m, :neteconomy, :DAMAGESCTRY, :damages, :DAMAGESCTRY)
            connect_param!(m, :neteconomy, :ABATECOSTctry, :emissions, :ABATECOSTctry)

            # OLD: Original RICE model
            connect_param!(m, :neteconomy, :DAMFRACOLD, :damages, :DAMFRACOLD)
            connect_param!(m, :neteconomy, :DAMAGESOLD, :damages, :DAMAGESOLD)

            # NEW: REDISTRIBUTION
            set_param!(m, :neteconomy, :REDISTbase, p[:REDISTbase])
            # set_param!(m, :neteconomy, :REDISTreg, p[:REDISTreg])
            connect_param!(m, :neteconomy, :REDISTreg, :emissions, :REDISTreg)
            connect_param!(m, :neteconomy, :REDIST, :emissions, :REDIST)

    # WELFARE COMPONENT
    set_param!(m, :welfare, :l, p[:l])
    set_param!(m, :welfare, :elasmu, p[:elasmu])
    set_param!(m, :welfare, :rr, p[:rr])
    set_param!(m, :welfare, :scale1, p[:scale1])
    set_param!(m, :welfare, :scale2, p[:scale2])
    set_param!(m, :welfare, :alpha, p[:alpha])

                # NEW: Pure rate of time preference & elasticity of marginal utility of consumption
                set_param!(m, :welfare, :rho, p[:rho])
                set_param!(m, :welfare, :eta, p[:eta])

    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

                # NEW: COUNTRY-LEVEL - Per Capita Consumption
                set_param!(m, :welfare, :inregion, p[:inregion])

                connect_param!(m, :welfare, :CPCctry, :neteconomy, :CPCctry)
                connect_param!(m, :welfare, :lctry, :neteconomy, :lctry)

    return m
end #function

function getrice(;datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000_v1.1s.xlsm"))
    params = getrice2010parameters(datafile)

    m = constructrice(params)

    return m, params # added params (as in NICE)
end #function

end #module
