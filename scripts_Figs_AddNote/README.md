Scripts for figures in "Additional note" of this comment
---
- Lists in YSR21 & YSR23-errata
   - YSR21_clcerr.csv
     - Table S2 in [YSR21](https://doi.org/10.1785/0220210232), generated as .csv file for easy read in scripts.
   - YSR23_relocation.csv
     - Table S1 in [YSR23-errata](https://doi.org/10.1785/0220230360), generated as .csv file for easy read in scripts.
   
- Figure A1. Residuals (dt(res)) based on the correction YSR23-errata and no effect of the instrument responses used between YSR21 and this comment. 


# Figure A2. (Un)reproducibility of YSR21’s “clock error” and examples of some irregularities in the correction YSR23-errata.
1. Collection of station info./seismic data of the "problematic" stations listed in YSR21
   - Most data could be accessed on IRIS via SOD, so info. of stations are read from SAC files.
   
   - For whose data unaccessible, info. of stations are directly got via SOD:
     - `find_stations -b yyyy-mm-dd -e yyyy-mm-dd -s StationName -n NetworkName`.
     
2. Recalculation of "clock errors" in Table S2 of YSR21.
3. Figure plot.

- Figure A3. Unrecoverable dt measurement in YSR21 for station OBN of doublet D2_1993-2004.
- Data: OBN.D2.yyyy.sac
