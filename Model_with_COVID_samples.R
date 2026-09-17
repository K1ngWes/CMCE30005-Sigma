### model including covid-19 period (2020-2024)

# install.packages(
#   c("ggplot2", "dplyr", "tidyr", "purrr", "broom", "gt")
# )

# Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(gt)

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


### RQ2: TIME-BASED TRAIN-TEST SPLIT

library(dplyr)

# Training data: 2002–2012
train_data <- industry_trend %>%
  filter(Year >= 2002, Year <= 2020)

# Test data: 2013–2018
test_data <- industry_trend %>%
  filter(Year >= 2021, Year <= 2024)

# Check that the split is correct
sort(unique(train_data$Year))
sort(unique(test_data$Year))

# check
range(train_data$Year)
range(test_data$Year)
range(test_predictions$Year)


### MODEL APPLICATION (predictive for RQ2)

# Linear Regression for All Industries
# Fit one separate regression model for each industry
industry_models <- train_data %>%
  group_by(Industry) %>%
  nest() %>%
  mutate(
    model = map(
      data,
      ~ lm(`Total establishments` ~ Year, data = .x)
    )
  )

# Summary table for all industries

industry_model_summary <- industry_models %>%
  mutate(
    model_results = map(model, tidy),
    model_fit = map(model, glance)
  ) %>%
  unnest(model_results) %>%
  filter(term == "Year") %>%
  select(
    Industry,
    Annual_change = estimate,
    Std_error = std.error,
    P_value = p.value
  ) %>%
  left_join(
    industry_models %>%
      mutate(model_fit = map(model, glance)) %>%
      unnest(model_fit) %>%
      select(Industry, R_squared = r.squared),
    by = "Industry"
  ) %>%
  arrange(Annual_change)

industry_model_summary


### LINEAR REGRESSION VISUALISATION

# predictions for every industry in the test set

test_predictions <- industry_models %>%
  select(Industry, model) %>%
  left_join(test_data, by = "Industry") %>%
  mutate(
    Predicted_establishments = map2_dbl(
      model,
      Year,
      ~ predict(.x, newdata = data.frame(Year = .y))
    )
  ) %>%
  select(
    Industry,
    Year,
    Actual_establishments = `Total establishments`,
    Predicted_establishments
  )

test_predictions

# display training obsevation

p_lr <- ggplot() +
  geom_line(
    data = train_data,
    aes(
      x = Year,
      y = `Total establishments`,
      group = Industry
    ),
    colour = "black"
  ) +
  geom_point(
    data = test_predictions,
    aes(
      x = Year,
      y = Actual_establishments
    ),
    colour = "#E57373",
    size = 2
  ) +
  geom_line(
    data = test_predictions,
    aes(
      x = Year,
      y = Predicted_establishments,
      group = Industry
    ),
    colour = "#377EB8",
    linetype = "dashed"
  ) +
  facet_wrap(
    ~ Industry,
    scales = "free_y",
    ncol = 4
  ) +
  labs(
    title = "Actual and Predicted SME Establishments by Industry",
    subtitle = "Black: training data | Red: actual test data | Blue: predictions",
    x = "Year",
    y = "Total establishments"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 9),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7)
  )

p_lr

# save
ggsave(
  filename = "LR_actual_vs_predicted.png",
  plot = p_lr,
  width = 14,
  height = 12,
  units = "in",
  dpi = 300,
  bg = "white"
)


### CHECK WHETHER THE PREDICTED DIRECTION WAS CORRECT

test_direction <- test_predictions %>%
  arrange(Industry, Year) %>%
  group_by(Industry) %>%
  summarise(
    Actual_test_change =
      last(Actual_establishments) -
      first(Actual_establishments),
    
    Predicted_test_change =
      last(Predicted_establishments) -
      first(Predicted_establishments),
    
    .groups = "drop"
  ) %>%
  mutate(
    Actual_test_direction = if_else(
      Actual_test_change < 0,
      "Decline",
      "Growth"
    ),
    
    Predicted_direction = if_else(
      Predicted_test_change < 0,
      "Decline",
      "Growth"
    ),
    
    Direction_correct =
      Actual_test_direction == Predicted_direction
  )

test_direction


### FINAL DECLINE ASSESSMENT

decline_assessment <- industry_model_summary %>%
  ungroup() %>%
  left_join(
    model_performance,
    by = "Industry"
  ) %>%
  left_join(
    test_direction,
    by = "Industry"
  ) %>%
  mutate(
    Historical_decline =
      Annual_change < 0 & P_value < 0.05,
    
    Continued_decline_in_test =
      Historical_decline &
      Actual_test_direction == "Decline",
    
    Prediction_accuracy = case_when(
      MAPE < 10 ~ "High",
      MAPE < 20 ~ "Moderate",
      TRUE ~ "Low"
    )
  ) %>%
  arrange(MAPE)

decline_assessment


# Final Result Display
decline_candidates <- decline_assessment %>%
  filter(Actual_test_change < 0) %>%
  mutate(
    Evidence_type = case_when(
      Historical_decline & Direction_correct ~
        "Persistent decline predicted by model",
      
      TRUE ~
        "Emerging decline not predicted by model"
    )
  ) %>%
  select(
    Industry,
    Annual_change,
    Actual_test_change,
    Predicted_test_change,
    Direction_correct,
    MAPE,
    Evidence_type
  ) %>%
  arrange(Actual_test_change)

decline_candidates


# -----------------------------------------------------------

### RQ3: Prescriptive

# Include all industries that declined during the assessment period
candidate_industries <- decline_candidates %>%
  pull(Industry)

candidate_industries


# Calculate employment change between 2002 and 2024
job_impact <- jobs_trend %>%
  filter(
    Industry %in% candidate_industries,
    Year %in% c(2002, 2024)
  ) %>%
  pivot_wider(
    names_from = Year,
    values_from = `Total jobs`,
    names_prefix = "Jobs_"
  ) %>%
  mutate(
    Job_change = Jobs_2024 - Jobs_2002,
    Jobs_lost = Jobs_2002 - Jobs_2024,
    Percentage_job_change =
      (Jobs_2024 - Jobs_2002) / Jobs_2002 * 100
  ) %>%
  arrange(desc(Jobs_lost))

job_impact


# combine employment impact with the existing persistence classification
rq3_priority <- decline_candidates %>%
  select(
    Industry,
    Annual_change,
    Actual_test_change,
    MAPE,
    Evidence_type
  ) %>%
  left_join(job_impact, by = "Industry") %>%
  arrange(desc(Jobs_lost))

rq3_priority


# haven't start working on the actual dataset from 2002-2024
# because the current model is not considered to be valid
# 


