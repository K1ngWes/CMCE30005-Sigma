# BAC-Grp-1
# CMCE30005 Business Analytics Challenge
## Sigma - Business Establishment - June 2026 Snapeshot

**Subject:** CMCE30005 Business Analytics Challenge, Semester 2 2026
**University:** University of Melbourne
**Team Members:** [Teresa Tan], [Ellen Zhang], [Wesley Kim], [Samuel Choong]

---

## Business Problem

Which SME industries in the Melbourne CBD are most at risk of continued decline,
and where should the City of Melbourne focus support? Using 23 years of CLUE data
(2002-2024) for 19 industries, we compare trends before and after COVID-19, forecast
establishments to 2029 with per-industry ARIMA models, and place each industry in a risk tier.


### Research Questions

1. How has the composition of SMEs in Melbourne CBD changed between 2002-2004?

2. Which SME industries in Melbourne CBD are most at risk of continued decline in establishments
   in the following 5 years?

3. Which declining SME industries should the City of Melbourne prioritise for support based on the
   persistence of establishment decline and employment impact?


### Dataset

**Dataset name:** Business Establishment - June 2026 Snapshot
**Source:**  Census of Land Use and Employment (CLUE)
**Coverage:** small and medium size businesses in the Melbourne CBD from 2002-2024


### Data Files

| File | Description | Size |
|------|-------------|------|
| `business-establishments-with-address-and-industry-classification.csv` | Address and industry | 76MB |
| `business-establishments-and-jobs-data-by-business-size-and-anzsic.csv` | Jobs data | 924KB |

   
### Methodology

**RQ1:** annual trends by industry, then percentage change before (2002-2019) and after (2019-2024) COVID-19.

**RQ2:** one ARIMA model per industry (`auto.arima`, lowest corrected AIC), refitted on 2002-2024 to forecast 2025-2029 with 80% intervals.

**Validation:** trained on 2002-2015, tested on 2016-2019; compared with a "no change" benchmark (MAPE) and an "always growth" baseline (direction accuracy). The split was chosen after comparing several, so results are indicative.

**RQ3:** each industry placed in a risk tier from three evidence points: decline before 2019, decline after 2019, and forecast decline to 2029. Jobs lost 2002-2024 show impact.


## 4. Analysis and Results
- 14 of 19 industries grew before 2019; 18 of 19 fell after (`outputs/figures/SME_covid_split.png`).
- Validation: direction accuracy 78.95% (15/19), precision 100%, recall 42.9%; ARIMA beat the no-change benchmark in 8 of 19 industries (7 tied, 4 worse).
- 2025-2029 forecast: only Transport has a forecast range wholly below its 2024 level; most other forecasts are flat or uncertain (`outputs/figures/ARIMA_future_forecast.png`).
- Risk tiers (`outputs/figures/risk_tier_chart.png`, `outputs/tables/risk_table.csv`):

| Tier | Industries |
|---|---|
| 1. High risk | Administrative and Support Services, Transport, Postal and Warehousing, Manufacturing |
| 2. Structural decline, forecast unclear | Information Media, Wholesale Trade |
| 3. Watch | Professional Services, Retail, Financial, Construction, Rental, Public Administration |
| 4. Too small to rank | Mining, Agriculture |
| 5. Low risk | Accommodation and Food, Education, Other Services, Health Care, Arts, Electricity |


## 5. Key Findings and Recommendations

**Findings:** the fall was broad and sudden; only five industries were already declining before 2019; the forecast confirms more than it discovers.

**Recommendations**
1. **Investigate before spending:** survey firms in the three high-risk industries to find out whether they are closing, relocating or shrinking; start with Transport.
2. **Re-run the analysis each census,** reading history first and the forecast second.
3. **No industry-specific rescue for the six watch industries yet;** use an early-warning rule (a further 10% fall moves an industry to high risk).


## 6. Limitations and Future Work
**Limitations:** the data cannot show why firms closed; each series has 23 observations; validation covers only 2016-2019 and misses shocks like COVID-19; the forecast flagged only 3 of 7 actual declines; suppressed job counts understate jobs.

**Future work:** use the address-level CLUE data to look inside high-risk industries; compare the CBD with other CLUE areas; add indicators such as office vacancy and pedestrian counts; revalidate on a post-2020 window.


## Project History
The interim report used per-industry linear regression on Year. Feedback showed this was unsuitable
for time-dependent data, so we tested rolling averages, then ARIMA, and compared several train/test splits.


### Tools

The analysis is conducted in R using packages including:

- dplyr
- ggplot2
- tidyr
- purrr
- broom
- gt
- zoo
- forecast


> **Note:** Data files are not committed to this repository due to size.
> Download from: [insert download URL or instructions]

---

*Last updated: 23/10/2026*
