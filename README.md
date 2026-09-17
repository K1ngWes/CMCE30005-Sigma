# BAC-Grp-1
# CMCE30005 Business Analytics Challenge
## Sigma - Business Establishment - June 2026 Snapshot

**Subject:** CMCE30005 Business Analytics Challenge, Semester 2 2026
**University:** University of Melbourne
**Team Members:** [Teresa Tan], [Ellen Zhang], [Wesley Kim], [Samuel Choong]

---

## Business Problem

[Write your one-paragraph problem statement here. Include: who is the stakeholder,
what question you are answering, why it matters, and what methods you plan to use.]


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





> **Note:** Data files are not committed to this repository due to size.
> Download from: [insert download URL or instructions]

---

*Last updated: 06/08/2026*
