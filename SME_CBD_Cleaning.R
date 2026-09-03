install.packages("ggplot2")
install.packages("dplyr")
library(dplyr)

business_establishments_and_jobs <- read.csv(
  "data/business-establishments-and-jobs-data-by-business-size-and-anzsic.csv",
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




# Vis 1 for all 19 industries: SME establishment trends by industry 
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


# Vis 2 



