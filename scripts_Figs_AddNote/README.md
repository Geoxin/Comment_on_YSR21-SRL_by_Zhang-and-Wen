Scripts for figures in "Additional note" of this comment
---
# Lists in YSR21 & YSR23-errata
1. YSR21_clcerr.csv
   Table S2 in [YSR21](https://doi.org/10.1785/0220210232), generated as .csv file for easy read in scripts.
2. YSR23_relocation.csv
   Table S1 in [YSR23-errata](https://doi.org/10.1785/0220230360), generated as .csv file for easy read in scripts.
   
# Figure A1. Residuals (dt(res)) based on the correction YSR23-errata and no effect of the instrument responses used between YSR21 and this comment. 
1. dt(res) computed based on corrected relocation results in the correction YSR23-erratra.
   - Align-YSR23errata.D1/D2: List of dt(pre), dt(res) for P waves at global stations of the doublet D1/D2.
   - Following the plotting style of Figs. 1 &3 in this comment.
2. Waveform alignment at OBN of data processed with instrument responses used in YSR21 and this comment.
   - Data processed with instrument responses in two studies:
     - YSR21: II.OBN.00.BHZ.M.xxxx.xxx.xxxxxx.SAC.bp.ysr21
       - Data: same as those used in this comment in [file](https://drive.google.com/drive/folders/1UTYFrVcsD4f5Gl1H8fE8Cw8pLZmHhQFF?usp=drive_link)
       - Instrument response: accessed in the [reply](https://github.com/yiyanguiuc/Data-used-in-Reply-to-Zhang-and-Wen). Also see [a duplication of the authors' archive](https://drive.google.com/file/d/1wNkmC2OmnrXnHrW1BGAVshxsK_vXWoDM/view?usp=drive_link). _NOTE: YSR21 instrument response of OBN is the same the version used in this comment, and is also identical with the version one could access at present on [IRIS](https://ds.iris.edu/mda/II/OBN/)_
     - This comment: OBN.D2.yyyy.sac
   - Following the plotting style of Fig. 5d in this comment.


# Figure A2. (Un)reproducibility of YSR21’s “clock error” and examples of some irregularities in the correction YSR23-errata.
1. Collection of station info./seismic data of the "problematic" stations listed in YSR21
   - Most data could be accessed on IRIS via SOD, so info. of stations are read from SAC files.
   
   - For whose data unaccessible, info. of stations are directly got via SOD:
     - `find_stations -b yyyy-mm-dd -e yyyy-mm-dd -s StationName -n NetworkName`
     
2. Recalculation of "clock errors" in Table S2 of YSR21.
3. Figure plot.

# Figure A3. Unrecoverable dt measurement in YSR21 for station OBN of doublet D2_1993-2004.
- Data: OBN.D2.yyyy.sac
