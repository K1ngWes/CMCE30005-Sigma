### ARIMA 
### Best Model with 78.95% Accuracy
### ARIMA models a time series using its own past values and past forecast errors, 
### with differencing to handle trends.


install.packages(c(
  "ggplot2",
  "dplyr",
  "tidyr",
  "purrr",
  "broom",
  "gt",
  "zoo",
  "forecast"
))

# Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(gt)
library(zoo)
library(forecast)

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


# RQ2 (predictive): ARIMA FORECAST  (replaces the rolling-average block)
# Run AFTER the code that creates industry_trend and jobs_trend

# settings
train_end <- 2015     # model only sees data up to this year
test_end  <- 2019     # forecast up to this year (use 2024 to include COVID)

# ---- 1. fit one ARIMA per industry on the training years, forecast ahead ----
# auto.arima() chooses the ARIMA(p,d,q) orders automatically (AIC-based).
# The forecast is multi-step from a fixed origin: no peeking at test years.
trend <- industry_trend %>%
  rename(Establishments = `Total establishments`) %>%
  arrange(Industry, Year)

test_predictions <- trend %>%
  group_by(Industry) %>%
  group_modify(~ {
    train <- .x %>% filter(Year <= train_end)
    test  <- .x %>% filter(Year > train_end, Year <= test_end)
    
    fit <- auto.arima(ts(train$Establishments, start = min(train$Year)))
    fc  <- forecast(fit, h = nrow(test))
    ord <- arimaorder(fit)[1:3]
    
    tibble(
      Year                     = test$Year,
      Actual_establishments    = test$Establishments,
      Predicted_establishments = as.numeric(fc$mean),
      Base                     = tail(train$Establishments, 1),   # last training value
      Naive_prediction         = tail(train$Establishments, 1),   # benchmark: no change
      ARIMA_order              = paste0("(", paste(ord, collapse = ","), ")")
    )
  }) %>%
  ungroup()

test_predictions

# which ARIMA orders were chosen? (useful for the report)
test_predictions %>% distinct(Industry, ARIMA_order)

# ---- 2. accuracy: ARIMA vs naive benchmark ----
model_performance <- test_predictions %>%
  filter(Actual_establishments > 0) %>%
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

# ---- 3. direction: did the ARIMA forecast get up/down right? ----
test_direction <- test_predictions %>%
  group_by(Industry) %>%
  summarise(
    Actual_test_change    = last(Actual_establishments)    - first(Base),
    Predicted_test_change = last(Predicted_establishments) - first(Base),
    .groups = "drop"
  ) %>%
  mutate(
    Actual_test_direction = if_else(Actual_test_change < 0, "Decline", "Growth"),
    Predicted_direction   = if_else(Predicted_test_change < 0, "Decline", "Growth"),
    Direction_correct     = Actual_test_direction == Predicted_direction
  )

test_direction

# headline numbers (compare with "always growth" baseline)
mean(test_direction$Direction_correct) * 100                  # model
mean(test_direction$Actual_test_direction == "Growth") * 100  # baseline


# 4. decline assessment 
decline_assessment <- test_direction %>%
  left_join(model_performance, by = "Industry") %>%
  mutate(
    Prediction_accuracy = case_when(
      MAPE < 10 ~ "High",
      MAPE < 20 ~ "Moderate",
      TRUE      ~ "Low"
    )
  ) %>%
  arrange(MAPE)

decline_assessment

decline_candidates <- decline_assessment %>%
  filter(Actual_test_change < 0) %>%
  mutate(
    Evidence_type = case_when(
      Direction_correct ~ "Decline predicted by ARIMA",
      TRUE              ~ "Emerging decline not predicted by ARIMA"
    )
  ) %>%
  select(Industry, Actual_test_change, Predicted_test_change,
         Direction_correct, MAPE, MAPE_naive, Beats_naive, Evidence_type) %>%
  arrange(Actual_test_change)

decline_candidates


decline_assessment %>%
  select(Industry, Actual_test_change, Predicted_test_change,
         Actual_test_direction, Predicted_direction, Direction_correct) %>%
  print(n = Inf, width = Inf)



# 5. plot 
p_arima <- ggplot() +
  geom_line(data = trend,
            aes(x = Year, y = Establishments, group = Industry),
            colour = "black") +
  geom_line(data = test_predictions,
            aes(x = Year, y = Predicted_establishments, group = Industry),
            colour = "#377EB8", linetype = "dashed") +
  geom_point(data = test_predictions,
             aes(x = Year, y = Actual_establishments),
             colour = "#E57373", size = 1.5) +
  facet_wrap(~ Industry, scales = "free_y", ncol = 4) +
  labs(
    title    = "Actual and ARIMA Forecast of SME Establishments by Industry",
    subtitle = paste0("Black: actual | Red: actual in test period | Blue: ARIMA forecast from ",
                      train_end),
    x = "Year", y = "Total establishments"
  ) +
  theme_minimal() +
  theme(strip.text  = element_text(size = 9),
        axis.text.x = element_text(size = 7),
        axis.text.y = element_text(size = 7))

p_arima

ggsave("ARIMA_actual_vs_predicted.png", plot = p_arima,
       width = 12, height = 10, units = "in", dpi = 300, bg = "white")


# test

test_direction

mean(test_direction$Direction_correct) * 100



table(Actual = test_direction$Actual_test_direction,
      Predicted = test_direction$Predicted_direction)



#----------------------------------------------------------------------

# RQ3 

# RQ3 step 1: candidate industries
# Takes the industries that actually declined in the test period from RQ2
# and lists their names. These are the industries we check for job impact.
# Output: a list of 7 industry names.
candidate_industries <- decline_candidates %>% pull(Industry)
candidate_industries


# RQ3 step 2: job impact of each candidate industry
# Compares total jobs in 2002 vs 2024 for those industries.
#   Job_change = Jobs_2024 - Jobs_2002 (negative = jobs fell)
#   Jobs_lost  = Jobs_2002 - Jobs_2024
#   (POSITIVE = jobs fell, NEGATIVE = jobs actually grew)
#   Percentage_job_change = change as a % of the 2002 job count
# Sorted so the biggest job losses are at the top.
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


# RQ3 step 3: priority table
# Joins the RQ2 results (change in establishments, forecast error MAPE,
# and whether the decline was predicted or "emerging") with the job impact
# above, giving one table to rank industries.
# Industries near the top lost the most jobs, so they are the highest priority.
rq3_priority <- decline_candidates %>%
  select(Industry, Actual_test_change, MAPE, Evidence_type) %>%
  left_join(job_impact, by = "Industry") %>%
  arrange(desc(Jobs_lost))

rq3_priority






