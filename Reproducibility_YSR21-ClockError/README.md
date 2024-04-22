Reproducibility test of the "clock errors" reported in YSR21 (Table S2 therein)
---
- List_clockerror_reproducibility
  - Lines with a "#" mark:
    - doublet name in YSR21-TableS2
    - [number of "problematic" stations reported in YSR21-TableS2]
  - Lines without a "#" mark:
    - station name
    - phase (of minimal difference from YSR21 reported "clock error")
    - dt prediction listed in YSR21-TableS2 (s)
    - dt prediction computed based on YSR23-errata in this reproducibility test (s)
    - difference of dt predition: [YSR21-this] (ms)
    - dt residual (i.e., "clock error") listed in YSR21-TableS2 (s)
    - dt residual computed based on YSR23-errata and YSR21-TableS2 in this reproducibility test (s)
    - difference of dt residual: [YSR21-this] (ms)

- List_eventpairs:
  - doublet ID (x-axis in Fig. A2a)
  - doublet name in YSR21-TableS2
  - [number of "problematic" stations reported in YSR21-TableS2]
 
      
- NOTE: _YSR21 stated that YSR21’s reported “clock errors” were calculated with respect to “the first mantle P arrivals if the distance is smaller than 104°, or the inner-core PKP arrivals if between 104° and 145°, or the outer-core PKP arrivals if greater than 145°”. The exact phase of use for each station was not stated in YSR21. Therefore, we here compute the clock error of a station with respect to all possible phases of firstly-arrived P, Pn, Pdiff, PKPab, PKPbc, PKiKP, PKPdf, and choose the calculated clock error that has the minimal difference from YSR21’s reported “clock error” in the reproducibility test._
