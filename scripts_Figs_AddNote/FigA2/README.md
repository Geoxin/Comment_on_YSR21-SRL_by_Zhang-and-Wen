Fig. A2.
---
* Perl script for plotting based on GMT-5.4.5:
	- FA2.pl
		>> FA2.ps
		>> List_dtAlign_all
		>> List_eventpairs

- Tables in YSR21 & YSR23-errata
	- YSR21_clcerr.csv: Table S2 in YSR21
	- YSR23_relocation.csv: Table S1 in YSR23-errata

- Scripts to get station & doublet infos.
 	* Most can be accessed by downloading data via SOD, the else can be further accessed by "find_stations" via SOD
	- 1.1_stadownlist.pl
	- 1.2_cycle-downSOD.pl
		- ./lib_downSOD/
		- data_evn1_evn2.num/download.xml
		- data_evn1_evn2.num/events_evn1_evn2.num.csv
	- 1.3_check-downloaded.pl
	- 2.1_output-reloinfo.pl

- Scripts to compute "clock error" in YSR21
	- 2.2_output-clrerr.pl
		<< List_multilocstas:
			some station infos. accessed by manual checking.
		>> List_stationinfos: stations directly found in data or find_stations; the else need to be accessed with manual checking.
	- 2.3_output-check.pl
		>> List_reproducibility

- Script to compute RMS of D1 & D2
	- 3_YSR23-dOrange.pl
		>> List_RMS_YSR23.D1
		>> List_RMS_YSR23.D2

- data_
	- data_evn1_evn2.num/Info_YSR23errata_evn1_evn2
	- data_evn1_evn2.num/Info_dtAlign
