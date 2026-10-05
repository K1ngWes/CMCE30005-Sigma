### FULL-DATA VERSION: ARIMA forecast (2025 onwards) + RQ3 priority
### The train/test script is the EVALUATION of this method.
### This script refits the same method on ALL data (2002-2024) to forecast the future.

#install.packages(c("ggplot2", "dplyr", "tidyr", "forecast"))  # run once

library(ggplot2)
library(dplyr)
library(tidyr)
library(forecast)

# settings
h_future  <- 5       # forecast horizon: 2025-2029 (keep short & data include COVID)
last_year <- 2024
include_long_run_decliners <- FALSE
# FALSE = RQ3 candidates are only industries forecast to decline
# TRUE  = also include industries that declined over 2002-2024 AND 2019-2024


# 1. LOAD AND CLEAN (same steps as the evaluation script)
business_establishments_and_jobs <- read.csv(
  "~/Desktop/BAC/business-establishments-and-jobs-data-by-business-size-and-anzsic.csv",
  check.names = FALSE
)

# SMEs only, Melbourne CBD only
sme_cbd <- business_establishments_and_jobs[
  business_establishments_and_jobs$`Business size` %in%
    c("Small business", "Medium business") &
    business_establishments_and_jobs$`CLUE small area` == "Melbourne (CBD)",
]

# total SME establishments by year and industry
industry_trend <- aggregate(
  sme_cbd[["Total establishments"]],
  by = list(Year = sme_cbd[["Census year"]], Industry = sme_cbd[[3]]),
  FUN = sum
)
names(industry_trend)[3] <- "Total establishments"

# total SME jobs by year and industry
jobs_trend <- aggregate(
  sme_cbd[["Total jobs"]],
  by = list(Year = sme_cbd[["Census year"]], Industry = sme_cbd[[3]]),
  FUN = sum,
  na.rm = TRUE
)
names(jobs_trend)[3] <- "Total jobs"

trend <- industry_trend %>%
  rename(Establishments = `Total establishments`) %>%
  arrange(Industry, Year)

# sanity check: ts() assumes consecutive years, so every industry should have
# one row for each year 2002-2024. This should print 0 rows.
trend %>% count(Industry) %>% filter(n != length(2002:2024))



### RQ2 FINAL FORECAST: one ARIMA per industry, fitted on 2002-2024
future_forecast <- trend %>%
  group_by(Industry) %>%
  group_modify(~ {
    fit <- auto.arima(ts(.x$Establishments, start = min(.x$Year)))
    fc  <- forecast(fit, h = h_future, level = 80)
    ord <- arimaorder(fit)[1:3]
    
    tibble(
      Year        = last_year + seq_len(h_future),
      Predicted   = as.numeric(fc$mean),
      Lower80     = as.numeric(fc$lower),
      Upper80     = as.numeric(fc$upper),
      Last_actual = tail(.x$Establishments, 1),
      ARIMA_order = paste0("(", paste(ord, collapse = ","), ")")
    )
  }) %>%
  ungroup()

future_forecast

# which ARIMA orders were chosen? (0,1,0) = flat "no change" forecast
future_forecast %>% distinct(Industry, ARIMA_order)

# outlook at the end of the forecast horizon
future_summary <- future_forecast %>%
  group_by(Industry) %>%
  summarise(
    ARIMA_order         = first(ARIMA_order),
    Establishments_2024 = first(Last_actual),
    Predicted_end       = last(Predicted),
    Lower80_end         = last(Lower80),
    Upper80_end         = last(Upper80),
    .groups = "drop"
  ) %>%
  mutate(
    Predicted_change = Predicted_end - Establishments_2024,
    Pct_change       = Predicted_change / Establishments_2024 * 100,
    Outlook = case_when(
      Predicted_change < 0 ~ "Decline",
      Predicted_change > 0 ~ "Growth",
      TRUE                 ~ "No change (flat forecast)"
    ),
    # confident only if the whole 80% range is on one side of the 2024 level
    Confidence = case_when(
      Upper80_end < Establishments_2024 ~ "Decline likely (range entirely below 2024)",
      Lower80_end > Establishments_2024 ~ "Growth likely (range entirely above 2024)",
      TRUE                              ~ "Uncertain (range includes 2024 level)"
    )
  ) %>%
  arrange(Predicted_change)

print(future_summary, n = Inf, width = Inf)


# Visualise table
install.packages("gt")
library(gt)

future_tbl <- future_summary %>%
  transmute(
    Industry,
    `2024 actual`   = Establishments_2024,
    `2029 forecast` = round(Predicted_end),
    `Change`        = round(Predicted_change),
    `Change (%)`    = round(Pct_change, 1),
    Outlook = if_else(Outlook == "Decline" | Outlook == "Growth",
                      Outlook, "No change"),
    Confidence = case_when(
      grepl("^Decline likely", Confidence) ~ "Decline likely",
      grepl("^Growth likely",  Confidence) ~ "Growth likely",
      TRUE                                 ~ "Uncertain"
    )
  ) %>%
  gt() %>%
  tab_header(title = "Forecast SME Establishments by Industry, 2024 to 2029") %>%
  tab_source_note("Confidence: 'likely' means the whole 80% forecast range is on one side of the 2024 level.")

future_tbl                                  
gtsave(future_tbl, "future_forecast_table.docx")



# plot: history + forecast + 80% range
# colour the forecast by outlook: red = forecast decline, blue = everything else
plot_forecast <- future_forecast %>%
  left_join(select(future_summary, Industry, Outlook), by = "Industry") %>%
  mutate(Group = if_else(Outlook == "Decline", "Forecast decline", "Other"))

p_future <- ggplot() +
  geom_line(data = trend,
            aes(x = Year, y = Establishments, group = Industry),
            colour = "black") +
  geom_ribbon(data = plot_forecast,
              aes(x = Year, ymin = Lower80, ymax = Upper80,
                  group = Industry, fill = Group),
              alpha = 0.25) +
  geom_line(data = plot_forecast,
            aes(x = Year, y = Predicted, group = Industry, colour = Group),
            linetype = "dashed", linewidth = 0.8) +
  scale_colour_manual(values = c("Forecast decline" = "#D32F2F", "Other" = "#377EB8"),
                      name = NULL) +
  scale_fill_manual(values = c("Forecast decline" = "#D32F2F", "Other" = "#377EB8"),
                    name = NULL) +
  facet_wrap(~ Industry, scales = "free_y", ncol = 4,
             labeller = label_wrap_gen(width = 25)) +
  labs(
    title    = "ARIMA Forecast of SME Establishments by Industry, 2025-2029",
    subtitle = "Black: actual 2002-2024 | Dashed and shaded: forecast with 80% range (red = forecast decline)",
    x = "Year", y = "Total establishments"
  ) +
  theme_minimal() +
  theme(strip.text      = element_text(size = 9),
        axis.text.x     = element_text(size = 7),
        axis.text.y     = element_text(size = 7),
        legend.position = "none")

p_future

ggsave("ARIMA_future_forecast.png", plot = p_future,
       width = 12, height = 10, units = "in", dpi = 300, bg = "white")



### 3. RQ3 (prescriptive): which declining industries to prioritise?


# RQ3 step 1: persistence of decline (historical, full data)
#   Long-run and recent decline    = fewer establishments in 2024 than 2002 AND than 2019
#   Recent decline only (post-2019)= grew over 2002-2024 but fell since 2019 (likely COVID)
persistence <- trend %>%
  group_by(Industry) %>%
  summarise(
    Change_2002_2024 = Establishments[Year == 2024] - Establishments[Year == 2002],
    Change_2019_2024 = Establishments[Year == 2024] - Establishments[Year == 2019],
    .groups = "drop"
  ) %>%
  mutate(
    Persistence = case_when(
      Change_2002_2024 < 0  & Change_2019_2024 < 0 ~ "Long-run and recent decline",
      Change_2002_2024 >= 0 & Change_2019_2024 < 0 ~ "Recent decline only (post-2019)",
      TRUE                                         ~ "Not declining"
    )
  )

persistence


# RQ3 step 2: employment impact, 2002 vs 2024, for ALL industries
#   Jobs_lost = Jobs_2002 - Jobs_2024
#   (POSITIVE = jobs fell, NEGATIVE = jobs actually grew)
job_impact_all <- jobs_trend %>%
  filter(Year %in% c(2002, 2024)) %>%
  pivot_wider(
    names_from   = Year,
    values_from  = `Total jobs`,
    names_prefix = "Jobs_"
  ) %>%
  mutate(
    Job_change = Jobs_2024 - Jobs_2002,
    Jobs_lost  = Jobs_2002 - Jobs_2024,
    Percentage_job_change = Job_change / Jobs_2002 * 100
  )

job_impact_all

# RQ3 step 3: priority table
# Candidates = industries the full-data ARIMA forecasts to decline
# (plus long-run decliners if include_long_run_decliners = TRUE).
# Sorted so industries with the biggest job losses are at the top.
rq3_priority <- future_summary %>%
  left_join(persistence,    by = "Industry") %>%
  left_join(job_impact_all, by = "Industry") %>%
  filter(
    Outlook == "Decline" |
      (include_long_run_decliners & Persistence == "Long-run and recent decline")
  ) %>%
  select(
    Industry,
    Predicted_change,        # forecast change in establishments, 2024 -> 2029
    Confidence,              # how clear the forecast is (80% range)
    Persistence,
    Change_2002_2024,
    Jobs_2002, Jobs_2024, Jobs_lost, Percentage_job_change
  ) %>%
  arrange(desc(Jobs_lost))

print(rq3_priority, n = Inf, width = Inf)


# 4. save
write.csv(future_summary, "future_summary.csv", row.names = FALSE)
write.csv(rq3_priority,   "rq3_priority.csv",   row.names = FALSE)