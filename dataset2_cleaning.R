## TERESA'S CHATGPT WORK FOR ADDRESS DATASET

library(tidyverse)

address_clean <- read_csv(
  "~/Documents/cmce30005 bac/business-establishments-with-address-and-industry-classification.csv",
  na = c("", "NA")
) %>%
  # Keep only Melbourne CBD
  filter(clue_small_area == "Melbourne (CBD)") %>%
  
  # Remove vacant premises — not operating establishments
  filter(
    industry_anzsic4_description != "Vacant Space",
    str_to_lower(str_trim(trading_name)) != "vacant"
  ) %>%
  
  # Standardise text fields
  mutate(
    trading_name = str_squish(str_to_upper(trading_name)),
    business_address = str_squish(str_to_upper(business_address)),
    industry_anzsic4_code = as.character(industry_anzsic4_code),
    industry_anzsic4_description = str_squish(industry_anzsic4_description)
  ) %>%
  
  # `point` duplicates longitude/latitude, so remove it
  select(-point)


