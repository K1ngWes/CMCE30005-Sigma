# BAC-Grp-1
# CMCE30005 Business Analytics Challenge
## Sigma - Business Establishment - June 2026 Snapshot

**Subject:** CMCE30005 Business Analytics Challenge, Semester 2 2026
**University:** University of Melbourne
**Team Members:** [Teresa Tan], [Ellen Zhang], [Wesley Kim], [Samuel Choong]

---

## Business Problem

Which SME industries in the Melbourne CBD are growing or declining, and which need
the most government support? Using 23 years (2002–2024) of CLUE data, we analyse 
establishment and job trends for 19 SME industries in the CBD, using per-industry 
linear regression to test which industries show statistically reliable decline and
predict which are most at risk going forward.


### Research Questions

1. How has the composition of SMEs in Melbourne CBD changed between 2002-2004?

2. Which SME industries in Melbourne CBD are most at risk of continued decline in establishments?

3. Which declining SME industries should the City of Melbourne prioritise for support based on the
   persistence of establishment decline and employment impact?

---

## Dataset

**Dataset name:** Business Establishment - June 2026 Snapshot
**Source:**  Census of Land Use and Employment (CLUE)
**Coverage:** small and medium size businesses in the Melbourne CBD from 2002-2024

### Data Files

| File | Description | Size |
|------|-------------|------|
| `business-establishments-with-address-and-industry-classification.csv` | Address and industry | ~size MB |
| `business-establishments-and-jobs-data-by-business-size-and-anzsic.csv` | Jobs data | ~size MB |

   
### Methodology

## RQ1 – Descriptive Analysis

Industry trends are examined using:
- Establishment numbers
- Total employment
- Absolute change
- Percentage change
- Industry share within CBD SMEs


## RQ2 – Predictive Analysis
Linear regression models are used to estimate establishment trends for each industry.

For model validation:
- Training period: 2002–2012
- Testing period: 2013–2018

The COVID-19 period was excluded from model testing because it represents an unusual 
structural disruption to normal business activity.

Model performance is evaluated by comparing the predicted and actual direction of change 
for each industry.


## RQ3 – Prescriptive Analysis
Industries showing persistent establishment decline are evaluated alongside their 
employment impact to identify industries that may warrant greater policy attention.


### Interim Progress

At the interim stage:

- Data cleaning and filtering for Dataset 1 have been completed.
- Descriptive analysis for RQ1 has been completed.
- The predictive model for RQ2 has been developed and tested.
- The model correctly predicted the direction of change for 14 of 19 industries in 
  the validation period.
- RQ3 methodology has been developed and will be refined in the final stage of the project.
- Evaluating the usefulness of dataset 2


### Next Steps

The next stage of the project will include:

- Keep refining the predictive methodology and decline threshold
- Applying the final model to the full dataset
- Completing the analysis of Dataset 2
- Integrating establishment and employment trends
- Developing final recommendations for the City of Melbourne

A More Detailed Version:

Remaining tasks: formal residual diagnostics on the regression models,
stakeholder-facing set of findings, incorporating Dataset 2 which is currently 
cleaned but not yet analysed, finalising the business problem statement and this 
content in the repository README.

Next steps: reconcile the 4-digit ANZSIC codes in Dataset 2 with the 19 broad 
categories in Dataset 1 so the two datasets can be cross-referenced, then produce 
the final integrated write-up and visual summary for submission, further data
processing, model development.


### Tools

The analysis is conducted in R using packages including:

- `dplyr`
- `ggplot2`
- `tidyr`
- `purrr`
- `broom`



> **Note:** Data files are not committed to this repository due to size.
> Download from: [insert download URL or instructions]

---

*Last updated: 18/09/2026*
