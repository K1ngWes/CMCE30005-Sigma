install.packages("ggplot2")


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
