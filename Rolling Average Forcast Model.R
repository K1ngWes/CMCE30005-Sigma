### Rolling-Average Forecast Model
### A Less Complicate Alternative of ARIMA
### Accuracy: 52.63%

install.packages(c(
  "ggplot2",
  "dplyr",
  "tidyr",
  "purrr",
  "broom",
  "gt",
  "zoo"
))

# Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(gt)
library(zoo)

business_establishments_and_jobs <- read.csv(
  "~/Desktop/BAC/business-establishments-and-jobs-data-by-business-size-and-anzsic.csv",
  check.names = FALSE
)

# check the rows of each business size
table(business_establishments_and_jobs[["Business size"]])

# keep business size for only SMEs
sme_data <- business_establishments_and_jobs[
  business_establishments_and_jobs$`Business size` %in%
    c("Small business", "Medium business"),
]

# keep only CBD area
sme_cbd <- sme_data[
  sme_data$`CLUE small area` == "Melbourne (CBD)",
]

dim(sme_data) # rows of SMEs 

dim(sme_cbd) # rows of SMEs in CBD area

unique(sme_cbd$`Census year`) 

table(sme_cbd$`Business size`)

table(sme_cbd[[3]])

# Filtering total establishment of SMEs in 2024 in each industries (not necessary just testing)
sme_2024 <- sme_cbd[
  sme_cbd[["Census year"]] == 2024,
]

industry_2024 <- aggregate(
  sme_2024[["Total establishments"]],
  by = list(Industry = sme_2024[[3]]),
  FUN = sum
)

names(industry_2024)[2] <- "Total establishments"

industry_2024 <- industry_2024[
  order(industry_2024$`Total establishments`, decreasing = TRUE),
]

industry_2024

# -------------

# aggregate total SME establishments by year and industry
industry_trend <- aggregate(
  sme_cbd[["Total establishments"]],
  by = list(
    Year = sme_cbd[["Census year"]],
    Industry = sme_cbd[[3]]
  ),
  FUN = sum
)

names(industry_trend)[3] <- "Total establishments"

head(industry_trend)

jobs_trend <- aggregate(
  sme_cbd[["Total jobs"]],
  by = list(
    Year = sme_cbd[["Census year"]],
    Industry = sme_cbd[[3]]
  ),
  FUN = sum,
  na.rm = TRUE
)

names(jobs_trend)[3] <- "Total jobs"

# check for missing values
sum(is.na(sme_cbd[["Total establishments"]]))
sum(is.na(sme_cbd[["Total jobs"]]))

sme_cbd[is.na(sme_cbd[["Total jobs"]]), ]


# a table for total establishments by industry (2024 only)
install.packages("gt")
library(gt)

industry_2024 %>%
  gt() %>%
  tab_header(
    title = "SME Establishments by Industry in Melbourne CBD, 2024"
  ) %>%
  tab_options(
    table.border.top.style = "solid",
    table.border.bottom.style = "solid",
    column_labels.border.bottom.style = "solid",
    table_body.hlines.style = "solid"
  )

# Summary Statistics
summary(sme_cbd)      # overall all for DS1

# or just the key variables
year_summary <- sme_cbd %>%
  group_by(`Census year`) %>%
  summarise(
    total_establishments = sum(`Total establishments`, na.rm = TRUE),
    total_jobs = sum(`Total jobs`, na.rm = TRUE)
  )

year_summary

# or 
names(sme_cbd) <- c(
  "Year",
  "Area",
  "Industry",
  "Business_size",
  "Total_establishments",
  "Total_jobs"
)

summary(sme_cbd$Total_establishments) # stat table for DS1 total establishment
summary(sme_cbd$Total_jobs)           # stat table for DS1 total jobs

year_summary <- sme_cbd %>%
  group_by(Year) %>%
  summarise(
    total_establishments = sum(Total_establishments, na.rm = TRUE),
    total_jobs = sum(Total_jobs, na.rm = TRUE)
  )

year_summary


### VISUALISATION DS1
### Vis 1 for all 19 industries: SME establishment trends by industry 

# already answers the descriptive question!!!

library(ggplot2)
ggplot(
  industry_trend,
  aes(
    x = Year,
    y = `Total establishments`
  )
) +
  geom_line() +
  facet_wrap(~ Industry, scales = "free_y") +
  labs(
    title = "SME Establishment Trends by Industry",
    x = "Year",
    y = "Total establishments"
  ) +
  theme_minimal()

# save
ggsave(
  "SME_industry_trends.png",
  width = 12,
  height = 8,
  dpi = 300
)

### Vis 2: integrate all 19 industries trend over time into same diagram
library(ggplot2)

ggplot(
  industry_trend,
  aes(
    x = Year,
    y = `Total establishments`,
    colour = Industry,
    group = Industry
  )
) +
  geom_line(linewidth = 1) +
  labs(
    title = "SME Establishment Trends by Industry",
    x = "Year",
    y = "Total establishments",
    colour = "Industry"
  ) +
  theme_minimal()

# save
ggsave(
  "SME_all_industry_trends.png",
  width = 12,
  height = 8,
  dpi = 300
)

### Vis 3
# try visualise the absolute changes
industry_change <- merge(
  industry_trend[industry_trend$Year == 2002, ],
  industry_trend[industry_trend$Year == 2024, ],
  by = "Industry",
  suffixes = c("_2002", "_2024")
)

industry_change$Change <-
  industry_change$`Total establishments_2024` -
  industry_change$`Total establishments_2002`

# plot: comparing the total SME establishments in each industry in 2002 vs 2024
# How much did the number of SME establishments change between the first year and the last year?
library(ggplot2)

ggplot(
  industry_change,
  aes(
    x = reorder(Industry, Change),
    y = Change
  )
) +
  geom_col(
    aes(fill = Change > 0)
  ) +
  scale_fill_manual(
    values = c("TRUE" = "#4CAF50", "FALSE" = "#E57373"),
    guide = "none"
  ) +
  coord_flip() +
  labs(
    title = "Change in SME Establishments by Industry, 2002–2024",
    x = NULL,
    y = "Change in establishments"
  ) +
  theme_minimal()

# save
ggsave(
  "SME_industry_change_2002_2024.png",
  width = 12,
  height = 8,
  dpi = 300
)


# check duplicates
library(dplyr)

sme_cbd %>%
  count(Year, Industry, Business_size) %>%
  filter(n > 1)

# check impossible establishment values
sum(sme_cbd$Total_establishments < 0, na.rm = TRUE)

# check impossible job values
sum(sme_cbd$Total_jobs < 0, na.rm = TRUE)



# -----------------------------------------------------------------------


# RQ2 (predictive): ROLLING-AVERAGE FORECAST  (replaces lm ~ Year)
# Run AFTER your existing code that creates industry_trend and jobs_trend


# ---- settings (easy to change / justify in the report) ----
window_size <- 3
test_start <- 2013
test_end <- 2018

origin <- test_start - 1

# ---- 1. rolling average of yearly change + one-step-ahead forecast ----

trend <- industry_trend %>%
  rename(Establishments = `Total establishments`) %>%
  arrange(Industry, Year) %>%
  group_by(Industry) %>%
  mutate(
    # actual yearly change
    Change = Establishments - lag(Establishments),
    
    # average change over the most recent 3 years
    Roll_change = rollapplyr(
      Change,
      width = window_size,
      FUN = mean,
      fill = NA,
      na.rm = TRUE
    ),
    
    # previous year's actual establishment count
    Previous_year = lag(Establishments),
    
    # TRUE one-step-ahead rolling forecast
    # prediction for year t only uses information up to t-1
    Predicted_establishments =
      lag(Establishments) + lag(Roll_change),
    
    # naive benchmark: assume no change
    Naive_prediction =
      lag(Establishments),
    
    # useful for direction evaluation later
    Actual_yearly_change =
      Establishments - lag(Establishments),
    
    Predicted_yearly_change =
      Predicted_establishments - lag(Establishments)
  ) %>%
  ungroup()


# ---- 2. test-period predictions ----

test_predictions <- trend %>%
  filter(
    Year >= test_start,
    Year <= test_end,
    !is.na(Predicted_establishments)
  ) %>%
  select(
    Industry,
    Year,
    Actual_establishments = Establishments,
    Previous_year,
    Predicted_establishments,
    Naive_prediction,
    Actual_yearly_change,
    Predicted_yearly_change
  )


# ---- 3. accuracy: rolling average vs naive benchmark ----
model_performance <- test_predictions %>%
  filter(Actual_establishments > 0) %>%     # avoid dividing by zero
  group_by(Industry) %>%
  summarise(
    MAPE       = mean(abs(Actual_establishments - Predicted_establishments) /
                        Actual_establishments) * 100,
    MAPE_naive = mean(abs(Actual_establishments - Naive_prediction) /
                        Actual_establishments) * 100,
    .groups = "drop"
  ) %>%
  mutate(Beats_naive = MAPE < MAPE_naive)

model_performance


# ---- 4. Did the PRE-TEST rolling trend correctly predict direction? ----

test_direction <- trend %>%
  group_by(Industry) %>%
  summarise(
    Recent_avg_change =
      Roll_change[Year == origin],
    
    Actual_test_change =
      Establishments[Year == test_end] -
      Establishments[Year == origin],
    
    .groups = "drop"
  ) %>%
  mutate(
    Actual_test_direction = if_else(
      Actual_test_change < 0,
      "Decline",
      "Growth"
    ),
    
    Predicted_direction = if_else(
      Recent_avg_change < 0,
      "Decline",
      "Growth"
    ),
    
    Direction_correct =
      Actual_test_direction == Predicted_direction
  )


# ---- 5. final decline assessment ----

decline_assessment <- test_direction %>%
  left_join(model_performance, by = "Industry") %>%
  mutate(
    Historical_decline = Recent_avg_change < 0,
    
    Prediction_accuracy = case_when(
      MAPE < 10 ~ "High",
      MAPE < 20 ~ "Moderate",
      TRUE ~ "Low"
    )
  ) %>%
  arrange(MAPE)

decline_assessment


# industries that actually declined in the test period

decline_candidates <- decline_assessment %>%
  filter(Actual_test_change < 0) %>%
  mutate(
    Evidence_type = case_when(
      Historical_decline & Direction_correct ~
        "Persistent decline flagged by rolling average",
      
      TRUE ~
        "Emerging decline not flagged by rolling average"
    )
  ) %>%
  select(
    Industry,
    Recent_avg_change,
    Actual_test_change,
    Actual_test_direction,
    Predicted_direction,
    Direction_correct,
    MAPE,
    MAPE_naive,
    Beats_naive,
    Evidence_type
  ) %>%
  arrange(Actual_test_change)

decline_candidates


# ---- 7. visualisation ----
p_roll <- ggplot() +
  geom_line(
    data = trend,
    aes(x = Year, y = Establishments, group = Industry),
    colour = "black"
  ) +
  geom_line(
    data = test_predictions,
    aes(x = Year, y = Predicted_establishments, group = Industry),
    colour = "#377EB8", linetype = "dashed"
  ) +
  geom_point(
    data = test_predictions,
    aes(x = Year, y = Actual_establishments),
    colour = "#E57373", size = 1.5
  ) +
  facet_wrap(~ Industry, scales = "free_y", ncol = 4) +
  labs(
    title = "Actual and Rolling-Average Forecast of SME Establishments by Industry",
    subtitle = paste0("Black: actual | Red: actual in test period | Blue: ",
                      window_size, "-year rolling-average one-step-ahead forecast"),
    x = "Year", y = "Total establishments"
  ) +
  theme_minimal() +
  theme(
    strip.text  = element_text(size = 9),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7)
  )

p_roll

ggsave("Rolling_actual_vs_predicted.png", plot = p_roll,
       width = 12, height = 10, units = "in", dpi = 300, bg = "white")



### test
test_direction

### Accuracy in percentage
mean(test_direction$Direction_correct) * 100




# RQ3 (prescriptive): job impact of declining industries
# same logic as before, now fed by the rolling-average results

candidate_industries <- decline_candidates %>% pull(Industry)
candidate_industries

job_impact <- jobs_trend %>%
  filter(
    Industry %in% candidate_industries,
    Year %in% c(2002, 2024)
  ) %>%
  pivot_wider(
    names_from  = Year,
    values_from = `Total jobs`,
    names_prefix = "Jobs_"
  ) %>%
  mutate(
    Job_change = Jobs_2024 - Jobs_2002,
    Jobs_lost  = Jobs_2002 - Jobs_2024,
    Percentage_job_change = (Jobs_2024 - Jobs_2002) / Jobs_2002 * 100
  ) %>%
  arrange(desc(Jobs_lost))

job_impact

rq3_priority <- decline_candidates %>%
  select(Industry, Recent_avg_change, Actual_test_change, MAPE, Evidence_type) %>%
  left_join(job_impact, by = "Industry") %>%
  arrange(desc(Jobs_lost))

rq3_priority



