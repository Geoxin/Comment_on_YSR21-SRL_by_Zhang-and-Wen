# Figure A2. 
### (Un)reproducibility of YSR21’s “clock error” and examples of some irregularities in the correction YSR23-errata.
* PA2.pl: Perl plotting script based on GMT-5.4.5.
1. Collection of station info./seismic data of the "problematic" stations listed in YSR21.
   1) Most data could be accessed on IRIS via SOD, so info. of stations are read from SAC files.
     - 1.1_stadownlist.pl
     - 1.2_cycle-downSOD.pl
   2)  For whose data unaccessible, info. of stations are directly got via [SOD](https://www.seis.sc.edu/sod/) (time consuming):
     - `find_stations -b yyyy-mm-dd -e yyyy-mm-dd -s StationName -n NetworkName`.
   3) Manual check is needed to avoid missing
     - 1.3_check-downloaded.pl & manual check
2. Relocation infos rearrange based on YSR23
   - 2.1_output-reloinfo.pl
3. Recalculation of "clock errors" in Table S2 of YSR21.
   - 2.2_output-clcerr.pl
      - << List_multilocstas
      - << data_evn1_evn2.num/Info_YSR23errata_evn1_evn2
      - << "ttimes" (Buland & Chapman, 1983; IASP91 based following YSR21) to get parameters like slowness
      - >> data_evn1_evn2.num/Info_dtAlign
   - 2.3_output-check.pl 
4. RMS of dt(res) for doublet D1
   - 3_YSR23-dOrange.pl
      - << ../Align-YSR23errata.D1
      - >> List_RMS_YSR23.D1
  
