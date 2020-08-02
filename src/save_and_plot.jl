############################################################################
# Export variable values
# ###########################################################################

# Do you want to save the results as CSV and plot the results? ("true" or "false")
saveresults = true
plotresults = true
foreignabatement = "H4-L8-GDPpre-cond-diffCPRICE"               # "none", "H4-L8-GDPpre-cond-diffCPRICE", "H4-L8-GDPpre-cond-uniCPRICE"


if saveresults

    # Name of folder to store your results in (a folder will be created with this name).
    results_folder = string("Opt", optimization, "_region_original_uni_rd-0.1-4H-8L-GDP-FA_T2")
    # dir_output = joinpath("C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/rc_project/temporary/", results_folder)

    # set output directory and make the results_folder
    dir_output = joinpath(dirname(@__FILE__), "../results", results_folder,"")
    mkdir(dir_output)

    if foreignabatement == "H4-L8-GDPpre-cond-diffCPRICE"
        writedlm(string(dir_output, "REDISTpotential.csv"), m[:emissions, :REDISTpotential], ",")
    elseif foreignabatement == "H4-L8-GDPpre-cond-uniCPRICE"

    end


    # Climate Dynamics
    writedlm(string(dir_output, "TATM.csv"), m[:climatedynamics, :TATM], ",")

    # DAMAGES
    writedlm(string(dir_output, "DAMAGES.csv"), m[:damages, :DAMAGES], ",")
    writedlm(string(dir_output, "DAMAGESCTRY.csv"), m[:damages, :DAMAGESCTRY], ",")
    writedlm(string(dir_output, "DAMAGESctryagg.csv"), m[:damages, :DAMAGESctryagg], ",")
    writedlm(string(dir_output, "DAMAGESOLD.csv"), m[:damages, :DAMAGESOLD], ",")

    writedlm(string(dir_output, "DAMAGESSLR.csv"), m[:damages, :DAMAGESSLR], ",")
    writedlm(string(dir_output, "DAMAGESSLRCTRY.csv"), m[:damages, :DAMAGESSLRCTRY], ",")
    writedlm(string(dir_output, "DAMAGESSLRctryagg.csv"), m[:damages, :DAMAGESSLRctryagg], ",")
    writedlm(string(dir_output, "DAMAGESSLROLD.csv"), m[:damages, :DAMAGESSLROLD], ",")

    writedlm(string(dir_output, "DAMAGESTATM.csv"), m[:damages, :DAMAGESTATM], ",")
    writedlm(string(dir_output, "DAMAGESTATMCTRY.csv"), m[:damages, :DAMAGESTATMCTRY], ",")
    writedlm(string(dir_output, "DAMAGESTATMctryagg.csv"), m[:damages, :DAMAGESTATMctryagg], ",")
    writedlm(string(dir_output, "DAMAGESTATMOLD.csv"), m[:damages, :DAMAGESTATMOLD], ",")

    # Damage Fraction
    writedlm(string(dir_output, "DAMFRAC.csv"), m[:damages, :DAMFRAC], ",")
    writedlm(string(dir_output, "DAMFRACCTRY.csv"), m[:damages, :DAMFRACCTRY], ",")
    writedlm(string(dir_output, "DAMFRACOLD.csv"), m[:damages, :DAMFRACOLD], ",")

    writedlm(string(dir_output, "DAMFRACSLR.csv"), m[:damages, :DAMFRACSLR], ",")
    writedlm(string(dir_output, "DAMFRACSLRCTRY.csv"), m[:damages, :DAMFRACSLRCTRY], ",")
    writedlm(string(dir_output, "DAMFRACSLROLD.csv"), m[:damages, :DAMFRACSLROLD], ",")

    writedlm(string(dir_output, "DAMFRACTATM.csv"), m[:damages, :DAMFRACTATM], ",")
    writedlm(string(dir_output, "DAMFRACTATMCTRY.csv"), m[:damages, :DAMFRACTATMCTRY], ",")
    writedlm(string(dir_output, "DAMFRACTATMOLD.csv"), m[:damages, :DAMFRACTATMOLD], ",")

    writedlm(string(dir_output, "n1.csv"), m[:damages, :n1], ",")
    writedlm(string(dir_output, "n2.csv"), m[:damages, :n2], ",")
    writedlm(string(dir_output, "n3.csv"), m[:damages, :n3], ",")

    writedlm(string(dir_output, "f1.csv"), m[:damages, :f1], ",")
    writedlm(string(dir_output, "f2.csv"), m[:damages, :f2], ",")
    writedlm(string(dir_output, "f3.csv"), m[:damages, :f3], ",")

    writedlm(string(dir_output, "a1.csv"), m[:damages, :a1], ",")
    writedlm(string(dir_output, "a2.csv"), m[:damages, :a2], ",")

    # Emissions
    writedlm(string(dir_output, "ABATECOST.csv"), m[:emissions, :ABATECOST], ",")
    writedlm(string(dir_output, "ABATECOSTctry.csv"), m[:emissions, :ABATECOSTctry], ",")
    writedlm(string(dir_output, "CCA.csv"), m[:emissions, :CCA], ",") # Cumulative industrial emissions
    writedlm(string(dir_output, "cost1.csv"), m[:emissions, :cost1], ",") # Adjusted cost for backstop
    writedlm(string(dir_output, "CPRICE.csv"), m[:emissions, :CPRICE], ",")
    writedlm(string(dir_output, "CPRICEtotal.csv"), m[:emissions, :CPRICEtotal], ",")
    writedlm(string(dir_output, "E.csv"), m[:emissions, :E], ",")
    writedlm(string(dir_output, "EIND.csv"), m[:emissions, :EIND], ",") # Industrial emissions (GtC per year)
    writedlm(string(dir_output, "EINDforeign.csv"), m[:emissions, :EINDforeign], ",") # Industrial emissions (GtC per year)
    writedlm(string(dir_output, "EINDdomestic.csv"), m[:emissions, :EINDdomestic], ",") # Industrial emissions (GtC per year)
    writedlm(string(dir_output, "etree.csv"), m[:emissions, :etree], ",")
    writedlm(string(dir_output, "MCABATE.csv"), m[:emissions, :MCABATE], ",")
    writedlm(string(dir_output, "MCABATEtotal.csv"), m[:emissions, :MCABATEtotal], ",")
    writedlm(string(dir_output, "MIU.csv"), m[:emissions, :MIU], ",") # Emissions Control Rate GHGs
    writedlm(string(dir_output, "MIUforeign.csv"), m[:emissions, :MIUforeign], ",") # Emissions Control Rate GHGs
    writedlm(string(dir_output, "MIUtotal.csv"), m[:emissions, :MIUtotal], ",") # Emissions Control Rate GHGs
    writedlm(string(dir_output, "MIUtotalcalc.csv"), m[:emissions, :MIUtotalcalc], ",") # Emissions Control Rate GHGs
    writedlm(string(dir_output, "ABATECOSTtotal.csv"), m[:emissions, :ABATECOSTtotal], ",")
    writedlm(string(dir_output, "ABATECOSTforeign.csv"), m[:emissions, :ABATECOSTforeign], ",")
    writedlm(string(dir_output, "ABATECOSTforeignpotential.csv"), m[:emissions, :ABATECOSTforeignpotential], ",")
    writedlm(string(dir_output, "ABATECOSTpotential.csv"), m[:emissions, :ABATECOSTpotential], ",")
    writedlm(string(dir_output, "pbacktime.csv"), m[:emissions, :pbacktime], ",")
    writedlm(string(dir_output, "REDISTregpotential.csv"), m[:emissions, :REDISTregpotential], ",")

    # Gross Economy
    writedlm(string(dir_output, "YGROSS.csv"), m[:grosseconomy, :YGROSS], ",")
    writedlm(string(dir_output, "YGROSSctry.csv"), m[:grosseconomy, :YGROSSctry], ",")
    writedlm(string(dir_output, "gdpshare.csv"), m[:grosseconomy, :gdpshare], ",")
    writedlm(string(dir_output, "al.csv"), m[:grosseconomy, :al], ",") # Total Factor Productivity (TFP)
    writedlm(string(dir_output, "K.csv"), m[:grosseconomy, :K], ",") # Capital stock (trillions 2005 US dollars)
    writedlm(string(dir_output, "k0.csv"), m[:grosseconomy, :k0], ",") # Initial capital value (trill 2005 USD)

    # Net Economy
    writedlm(string(dir_output, "C.csv"), m[:neteconomy, :C], ",")
    writedlm(string(dir_output, "Cctry.csv"), m[:neteconomy, :Cctry], ",")
    writedlm(string(dir_output, "CPC.csv"), m[:neteconomy, :CPC], ",")
    writedlm(string(dir_output, "CPCctry.csv"), m[:neteconomy, :CPCctry], ",")
    writedlm(string(dir_output, "Y.csv"), m[:neteconomy, :Y], ",")
    writedlm(string(dir_output, "YNET.csv"), m[:neteconomy, :YNET], ",")
    writedlm(string(dir_output, "YNETpr.csv"), m[:neteconomy, :YNETpr], ",")
    writedlm(string(dir_output, "Yctry.csv"), m[:neteconomy, :Yctry], ",")
    writedlm(string(dir_output, "REDISTbase.csv"), m[:neteconomy, :REDISTbase], ",")
    writedlm(string(dir_output, "REDIST.csv"), m[:neteconomy, :REDIST], ",")
    writedlm(string(dir_output, "REDISTreg.csv"), m[:neteconomy, :REDISTreg], ",")
    writedlm(string(dir_output, "REDISTregpotential.csv"), m[:emissions, :REDISTregpotential], ",")
    writedlm(string(dir_output, "REDISTregperYNET.csv"), m[:neteconomy, :REDISTregperYNET], ",")
    writedlm(string(dir_output, "REDISTregperYNETpr.csv"), m[:neteconomy, :REDISTregperYNETpr], ",")
    writedlm(string(dir_output, "REDISTregperYNETpre.csv"), m[:neteconomy, :REDISTregperYNETpre], ",")
    writedlm(string(dir_output, "REDISTregperYNETprepr.csv"), m[:neteconomy, :REDISTregperYNETprepr], ",")
    writedlm(string(dir_output, "I.csv"), m[:neteconomy, :I], ",") # Investment (trillions 2005 USD per year)
    writedlm(string(dir_output, "Ictry.csv"), m[:neteconomy, :Ictry], ",")
    writedlm(string(dir_output, "S.csv"), m[:neteconomy, :S], ",")

    # SLR
    writedlm(string(dir_output, "TOTALSLR.csv"), m[:sealevelrise, :TOTALSLR], ",")

    # Welfare
    writedlm(string(dir_output, "CEMUTOTPERNOnegishi.csv"), m[:welfare, :CEMUTOTPERNOnegishi], ",")
    writedlm(string(dir_output, "CEMUTOTPERNOnegishiPC.csv"), m[:welfare, :CEMUTOTPERNOnegishiPC], ",")
    writedlm(string(dir_output, "CEMUTOTPERctryNOnegishi.csv"), m[:welfare, :CEMUTOTPERctryNOnegishi], ",")
    writedlm(string(dir_output, "CEMUTOTPERctryNOnegishiPC.csv"), m[:welfare, :CEMUTOTPERctryNOnegishiPC], ",")

    writedlm(string(dir_output, "PERIODUNOnegishi.csv"), m[:welfare, :PERIODUNOnegishi], ",")
    writedlm(string(dir_output, "PERIODUctryNOnegishi.csv"), m[:welfare, :PERIODUctryNOnegishi], ",")

    writedlm(string(dir_output, "REGCUMCEMUTOTPERNOnegishi.csv"), m[:welfare, :REGCUMCEMUTOTPERNOnegishi], ",")
    writedlm(string(dir_output, "REGCUMCEMUTOTPERNOnegishiPC.csv"), m[:welfare, :REGCUMCEMUTOTPERNOnegishiPC], ",")
    writedlm(string(dir_output, "REGCUMCEMUTOTPERctryNOnegishi.csv"), m[:welfare, :REGCUMCEMUTOTPERctryNOnegishi], ",")
    writedlm(string(dir_output, "REGCUMCEMUTOTPERctryNOnegishiPC.csv"), m[:welfare, :REGCUMCEMUTOTPERctryNOnegishiPC], ",")

    writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescale], ",")
    writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescalePC], ",")
    writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescale], ",")
    writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescalePC], ",")

    writedlm(string(dir_output, "UTILITYNOnegishiNOrescale.csv"), m[:welfare, :UTILITYNOnegishiNOrescale], ",")
    writedlm(string(dir_output, "UTILITYctryaggNOnegishiNOrescale.csv"), m[:welfare, :UTILITYctryaggNOnegishiNOrescale], ",")

    writedlm(string(dir_output, "UTILITYNOnegishiNOrescalePC.csv"), m[:welfare, :UTILITYNOnegishiNOrescalePC], ",")
    writedlm(string(dir_output, "UTILITYctryaggNOnegishiNOrescalePC.csv"), m[:welfare, :UTILITYctryaggNOnegishiNOrescalePC], ",")

    writedlm(string(dir_output, "UTILITY.csv"), m[:welfare, :UTILITY], ",")
    writedlm(string(dir_output, "UTILITYctryagg.csv"), m[:welfare, :UTILITYctryagg], ",")

    # Population
    writedlm(string(dir_output, "lctry.csv"), m[:neteconomy, :lctry], ",")
    writedlm(string(dir_output, "l.csv"), m[:neteconomy, :l], ",")
    writedlm(string(dir_output, "popshare.csv"), m[:neteconomy, :popshare], ",")

end

## PLOT

if plotresults

    using RCall

    function global_plot(data)
      R"""
        library(ggplot2)
        library(cowplot)
        library(tidyverse)
        library(sf)
        library(haven) # for import from dta format
        library(gridExtra) # for combining multiple graphs in one grid
        library(ggpubr)
        library(RColorBrewer)
        library(dplyr)

        data = $data

        # read in the data for the global level
        df <- read.csv(paste0($dir_output, data, ".csv"), header=FALSE)
        names(df) <- c("data")

        df_years <- data.frame("year" = seq(2005, 2595, 10))

        df <- df %>%
          bind_cols(df_years)

          # Plot for DAMFRAC region-level vs country-level
          dataplot <- ggplot(df) +
            geom_line(data = df, aes(x=year, y=data), colour = "red") +
            # geom_line(aes(x=year, y=data, color = riceregionname), size = 1.3) +
            labs(fill = "pcGDP") +
            # colScaleReg +
            xlab("Year") +
            ylab(data) +
            labs(title = paste($results_folder)) +
            # coord_cartesian(ylim = c(0, 6.7)) +
            # graphFormat +
            theme_bw() +
            theme(plot.title = element_text(size = 8))
          theme(axis.text = element_blank(), axis.line = element_blank(), axis.ticks = element_blank())

          print(dataplot)

          ggsave(paste0($dir_output, data, ".png"), device = "png", width = 4, height = 4) # I deleted dpi here
      """
    end


    function region_plot(data)
      R"""
        library(ggplot2)
        library(cowplot)
        library(tidyverse)
        library(sf)
        library(haven) # for import from dta format
        library(gridExtra) # for combining multiple graphs in one grid
        library(ggpubr)
        library(RColorBrewer)
        library(dplyr)

        data = $data

        modelyears <- seq(2005, 2595, by=10)

        # read in the data for region-level
        df <- read.csv(paste0($dir_output, data, ".csv"), header=FALSE)
        names(df) <- c("US", "EU", "Japan", "Russia", "Eurasia", "China", "India", "MidEast", "Africa", "LatAm", "OHI", "OthAs")

        df <- df %>%
          mutate(year = modelyears) %>%
          gather("riceregionname", data, -year)

        # Plot for DAMFRAC region-level vs country-level
        dataplot <- ggplot(df) +
          # geom_line(data = dfctry, aes(x=year, y=datactry, group = ricecountryname), colour = "grey") +
          geom_line(aes(x=year, y=data, color = riceregionname), size = 0.5) +
          labs(fill = "pcGDP") +
          # colScaleReg +
          xlab("Year") +
          ylab(data) +
          labs(title = paste($results_folder)) +
          # coord_cartesian(ylim = c(0, 400)) +
          # graphFormat +
          theme_bw() +
          theme(plot.title = element_text(size = 8))
        theme(axis.text = element_blank(), axis.line = element_blank(), axis.ticks = element_blank())
        # if(withtitles) data_CvR <- data_CvR +
          labs(title = paste("SLR Damages in trillions 2015 USD per year"))

        print(dataplot)

        ggsave(paste0($dir_output, data, ".png"), device = "png", width = 5, height = 4)
      """
    end

    function country_plot(data)
      R"""
        library(ggplot2)
        library(cowplot)
        library(tidyverse)
        library(sf)
        library(haven) # for import from dta format
        library(gridExtra) # for combining multiple graphs in one grid
        library(ggpubr)
        library(RColorBrewer)
        library(dplyr)

        data = $data

        modelyears <- seq(2005, 2595, by=10)

        # read in the data for country-level
        df <- read.csv(paste0($dir_output, data, ".csv"), header=FALSE)
        names(df) <- c("AFG",	"AGO",	"ALB",	"ARE",	"ARG",	"ARM",	"AUS",	"AUT",	"AZE",	"BDI",	"BEL",	"BEN",	"BFA",	"BGD",	"BGR",	"BHR",	"BHS",	"BIH",	"BLR",	"BLZ",	"BOL",	"BRA",	"BRB",	"BRN",	"BTN",	"BWA",	"CAF",	"CAN",	"CHE",	"CHL",	"CHN",	"CIV",	"CMR",	"COD",	"COG",	"COL",	"COM",	"CPV",	"CRI",	"CUB",	"CYP",	"CZE",	"DEU",	"DJI",	"DNK",	"DOM",	"DZA",	"ECU",	"EGY",	"ERI",	"ESP",	"EST",	"ETH",	"FIN",	"FJI",	"FRA",	"GAB",	"GBR",	"GEO",	"GHA",	"GIN",	"GMB",	"GNB",	"GNQ",	"GRC",	"GRD",	"GTM",	"GUM",	"GUY",	"HKG",	"HND",	"HRV",	"HTI",	"HUN",	"IDN",	"IND",	"IRL",	"IRN",	"IRQ",	"ISL",	"ISR",	"ITA",	"JAM",	"JOR",	"JPN",	"KAZ",	"KEN",	"KGZ",	"KHM",	"KOR",	"KWT",	"LAO",	"LBN",	"LBR",	"LBY",	"LCA",	"LKA",	"LSO",	"LTU",	"LUX",	"LVA",	"MAR",	"MDA",	"MDG",	"MEX",	"MKD",	"MLI",	"MMR",	"MNE",	"MNG",	"MOZ",	"MRT",	"MUS",	"MWI",	"MYS",	"NAM",	"NCL",	"NER",	"NGA",	"NIC",	"NLD",	"NOR",	"NPL",	"NZL",	"OMN",	"PAK",	"PAN",	"PER",	"PHL",	"PNG",	"POL",	"PRI",	"PRK",	"PRT",	"PRY",	"PSE",	"QAT",	"ROU",	"RUS",	"RWA",	"SAU",	"SDN",	"SEN",	"SLB",	"SLE",	"SLV",	"SOM",	"SRB",	"STP",	"SUR",	"SVK",	"SVN",	"SWE",	"SWZ",	"SYR",	"TCD",	"TGO",	"THA",	"TJK",	"TKM",	"TLS",	"TON",	"TTO",	"TUN",	"TUR",	"TZA",	"UGA",	"UKR",	"URY",	"USA",	"UZB",	"VCT",	"VEN",	"VIR",	"VNM",	"VUT",	"WSM",	"YEM",	"ZAF",	"ZMB",	"ZWE")

        df_emptycountries <- data.frame("allcountries" = c("countries"), "ricecountryname" = c("AFG",	"AGO",	"ALB",	"ARE",	"ARG",	"ARM",	"AUS",	"AUT",	"AZE",	"BDI",	"BEL",	"BEN",	"BFA",	"BGD",	"BGR",	"BHR",	"BHS",	"BIH",	"BLR",	"BLZ",	"BOL",	"BRA",	"BRB",	"BRN",	"BTN",	"BWA",	"CAF",	"CAN",	"CHE",	"CHL",	"CHN",	"CIV",	"CMR",	"COD",	"COG",	"COL",	"COM",	"CPV",	"CRI",	"CUB",	"CYP",	"CZE",	"DEU",	"DJI",	"DNK",	"DOM",	"DZA",	"ECU",	"EGY",	"ERI",	"ESP",	"EST",	"ETH",	"FIN",	"FJI",	"FRA",	"GAB",	"GBR",	"GEO",	"GHA",	"GIN",	"GMB",	"GNB",	"GNQ",	"GRC",	"GRD",	"GTM",	"GUM",	"GUY",	"HKG",	"HND",	"HRV",	"HTI",	"HUN",	"IDN",	"IND",	"IRL",	"IRN",	"IRQ",	"ISL",	"ISR",	"ITA",	"JAM",	"JOR",	"JPN",	"KAZ",	"KEN",	"KGZ",	"KHM",	"KOR",	"KWT",	"LAO",	"LBN",	"LBR",	"LBY",	"LCA",	"LKA",	"LSO",	"LTU",	"LUX",	"LVA",	"MAR",	"MDA",	"MDG",	"MEX",	"MKD",	"MLI",	"MMR",	"MNE",	"MNG",	"MOZ",	"MRT",	"MUS",	"MWI",	"MYS",	"NAM",	"NCL",	"NER",	"NGA",	"NIC",	"NLD",	"NOR",	"NPL",	"NZL",	"OMN",	"PAK",	"PAN",	"PER",	"PHL",	"PNG",	"POL",	"PRI",	"PRK",	"PRT",	"PRY",	"PSE",	"QAT",	"ROU",	"RUS",	"RWA",	"SAU",	"SDN",	"SEN",	"SLB",	"SLE",	"SLV",	"SOM",	"SRB",	"STP",	"SUR",	"SVK",	"SVN",	"SWE",	"SWZ",	"SYR",	"TCD",	"TGO",	"THA",	"TJK",	"TKM",	"TLS",	"TON",	"TTO",	"TUN",	"TUR",	"TZA",	"UGA",	"UKR",	"URY",	"USA",	"UZB",	"VCT",	"VEN",	"VIR",	"VNM",	"VUT",	"WSM",	"YEM",	"ZAF",	"ZMB",	"ZWE"), stringsAsFactors = FALSE)

        df <- df %>%
          mutate(year = modelyears) %>%
          gather("ricecountryname", data, -year)

          # Plot for DAMFRAC region-level vs country-level
          dataplot <- ggplot(df) +
            # geom_line(data = dfctry, aes(x=year, y=data, group = ricecountryname), colour = "grey") +
            geom_line(aes(x=year, y=data, color = ricecountryname), size = 0.5) +
            labs(fill = "pcGDP") +
            # colScaleReg +
            xlab("Year") +
            ylab(data) +
            labs(title = paste($results_folder)) +
            # coord_cartesian(ylim = c(0, 400)) +
            # graphFormat +
            theme_bw() +
            theme(plot.title = element_text(size = 8)) +
            theme(legend.position = "none")
          theme(axis.text = element_blank(), axis.line = element_blank(), axis.ticks = element_blank())
          # if(withtitles) data_CvR <- data_CvR +
            labs(title = paste("SLR Damages in trillions 2015 USD per year"))

          print(dataplot)

          ggsave(paste0($dir_output, data, ".png"), device = "png", width = 5, height = 4)
      """
    end


    if foreignabatement == "H4-L8-GDPpre-cond-diffCPRICE"
            global_plot("REDISTpotential")
    elseif foreignabatement == "H4-L8-GDPpre-cond-uniCPRICE"

    end

    country_plot("DAMAGESCTRY")

    ## GLOBAL PLOTS
    global_plot("TATM")
    global_plot("E")
    global_plot("CCA")
    global_plot("etree")
    global_plot("REDIST")
    global_plot("REDISTbase")
    global_plot("TOTALSLR")

    ## REGION PLOTS

    # Region redistribution
    region_plot("REDISTreg")
    region_plot("REDISTregpotential")
    region_plot("REDISTregperYNET")
    region_plot("REDISTregperYNETpr")
    region_plot("REDISTregperYNETpre")
    region_plot("REDISTregperYNETprepr")

    # Foreign abatement
    region_plot("MIUtotal")
    region_plot("MIUtotalcalc")
    region_plot("MIUforeign")
    region_plot("ABATECOSTtotal")
    region_plot("ABATECOSTforeign")
    region_plot("ABATECOSTforeignpotential")
    region_plot("ABATECOSTpotential")
    region_plot("EINDforeign")
    region_plot("EINDdomestic")


    # Damages plots
    region_plot("DAMAGES")
    region_plot("DAMAGESctryagg")
    region_plot("DAMAGESOLD")

    region_plot("DAMAGESSLR")
    region_plot("DAMAGESSLRctryagg")
    region_plot("DAMAGESSLROLD")

    region_plot("DAMAGESTATM")
    region_plot("DAMAGESTATMctryagg")
    region_plot("DAMAGESOLD")

    # DAMFRAC plots
    region_plot("DAMFRAC")
    region_plot("DAMFRACOLD")

    region_plot("DAMFRACSLR")
    region_plot("DAMFRACSLROLD")

    region_plot("DAMFRACTATM")
    region_plot("DAMFRACTATMOLD")

    # Emissions & Abatement plots
    region_plot("ABATECOST")
    region_plot("cost1")
    region_plot("CPRICE")
    region_plot("CPRICEtotal")
    region_plot("EIND")
    region_plot("MCABATE")
    region_plot("MCABATEtotal")
    region_plot("MIU")
    region_plot("pbacktime")

    # Gross Economy plots
    region_plot("YGROSS")
    region_plot("al")
    region_plot("K")

    # Net Economy Plots
    region_plot("C")
    region_plot("CPC")
    region_plot("Y")
    region_plot("I")
    region_plot("S")
    region_plot("YNET")
    region_plot("YNETpr")

    #
    region_plot("CEMUTOTPERNOnegishi")
    region_plot("CEMUTOTPERNOnegishiPC")
    region_plot("PERIODUNOnegishi")
    region_plot("REGCUMCEMUTOTPERNOnegishi")
    region_plot("REGCUMCEMUTOTPERNOnegishiPC")

    # Population
    region_plot("l")


    ## COUNTRY PLOTS
    country_plot("DAMAGESCTRY")
    country_plot("DAMAGESSLRCTRY")
    country_plot("DAMAGESTATMCTRY")
    country_plot("DAMFRACCTRY")
    country_plot("DAMFRACSLRCTRY")
    country_plot("DAMFRACTATMCTRY")
    country_plot("ABATECOSTctry")
    country_plot("YGROSSctry")
    country_plot("Cctry")
    country_plot("CPCctry")
    country_plot("Yctry")
    country_plot("Ictry")

    country_plot("CEMUTOTPERctryNOnegishi")
    country_plot("CEMUTOTPERctryNOnegishiPC")
    country_plot("PERIODUctryNOnegishi")
    country_plot("REGCUMCEMUTOTPERctryNOnegishi")
    country_plot("REGCUMCEMUTOTPERctryNOnegishiPC")
    country_plot("lctry")

end




## No Plots created yet for:

# writedlm(string(dir_output, "n1.csv"), m[:damages, :n1], ",")
# writedlm(string(dir_output, "n2.csv"), m[:damages, :n2], ",")
# writedlm(string(dir_output, "n3.csv"), m[:damages, :n3], ",")
# writedlm(string(dir_output, "f1.csv"), m[:damages, :f1], ",")
# writedlm(string(dir_output, "f2.csv"), m[:damages, :f2], ",")
# writedlm(string(dir_output, "f3.csv"), m[:damages, :f3], ",")
# writedlm(string(dir_output, "a1.csv"), m[:damages, :a1], ",")
# writedlm(string(dir_output, "a2.csv"), m[:damages, :a2], ",")
#
# # Gross Economy
# writedlm(string(dir_output, "gdpshare.csv"), m[:grosseconomy, :gdpshare], ",")
# writedlm(string(dir_output, "k0.csv"), m[:grosseconomy, :k0], ",") # Initial capital value (trill 2005 USD)
#
# # Welfare
# writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescale], ",")
# writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescalePC], ",")
# writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescale], ",")
# writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescalePC], ",")
#
# writedlm(string(dir_output, "UTILITYNOnegishiNOrescale.csv"), m[:welfare, :UTILITYNOnegishiNOrescale], ",")
# writedlm(string(dir_output, "UTILITYctryaggNOnegishiNOrescale.csv"), m[:welfare, :UTILITYctryaggNOnegishiNOrescale], ",")
#
# writedlm(string(dir_output, "UTILITYNOnegishiNOrescalePC.csv"), m[:welfare, :UTILITYNOnegishiNOrescalePC], ",")
# writedlm(string(dir_output, "UTILITYctryaggNOnegishiNOrescalePC.csv"), m[:welfare, :UTILITYctryaggNOnegishiNOrescalePC], ",")
#
# writedlm(string(dir_output, "UTILITY.csv"), m[:welfare, :UTILITY], ",")
# writedlm(string(dir_output, "UTILITYctryagg.csv"), m[:welfare, :UTILITYctryagg], ",")
#
# # Population
# writedlm(string(dir_output, "lctry.csv"), m[:neteconomy, :lctry], ",")
# writedlm(string(dir_output, "popshare.csv"), m[:neteconomy, :popshare], ",")
