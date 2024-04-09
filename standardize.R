library(tidyverse)
library(here)
library(readxl)

# read in original_data
co_gsi <- read_excel("original_data/IYS2022_Coho_genetic_tissue_GCL_IYS_key_2023-08-25_ER.xlsx")|> 
  select("IYS_Specimen_ID" = specimen_id, "IAgroup" = resolved_stock_id)
# check for duplicates
sum(duplicated(co_gsi$IYS_Specimen_ID))

co_dups <- co_gsi |> 
  group_by(IYS_Specimen_ID) |> 
  summarize(n = n()) |> 
  filter(n > 1)

cu_gsi <- read_csv("original_data/IYS chum individual assignments_4.4.24.csv")
# check for duplicates
sum(duplicated(cu_gsi$IYS_Specimen_ID))

cu_dups <- cu_gsi |> 
  group_by(IYS_Specimen_ID) |> 
  summarize(n = n()) |> 
  filter(n > 1)

so_gsi <- read_csv("original_data/2022_IYS_sockeye_assignments_4.4.24.csv")
# check for duplicates
sum(duplicated(so_gsi$IYS_Specimen_ID))

so_dups <- so_gsi |> 
  group_by(IYS_Specimen_ID) |> 
  summarize(n = n()) |> 
  filter(n > 1)

#TODO: Add back in chum and sockeye once duplicates are resolved

# combine data
gsi_2022 <- bind_rows(co_gsi, cu_gsi, so_gsi) |> 
  select("specimen_id" = IYS_Specimen_ID, IAgroup) |> 
  # find and replace "CanTrawl" with "Trawl" in specimen_id string
  mutate(specimen_id = str_replace(specimen_id, "CanTrawl", "Trawl"))

# find sum of NA in specimen_id
sum(is.na(gsi_2022$specimen_id))

# rsync IDC specimen data or download manually
# system("rsync -avz /Users/brettjohnson/R\\ Projects/IYS/IYS-Integrated-Data-Collection/output_datasets/IYS_trawl_specimen.csv .")
# 
# # Test to make sure matches exist in IYS Integrated Data Collection
# idc_specimen <- read_csv("IYS_trawl_specimen.csv")
# 
# qc_check <- inner_join(gsi_2022, idc_specimen, by = "specimen_id") |> 
#   select(specimen_id, IAgroup)

#generate summary table and plot of gsi_2022
gsi_2022_summary <- gsi_2022 |> 
  group_by(IAgroup) |> 
  summarize(n = n()) |> 
  arrange(desc(n))

# save summary csv
write_csv(gsi_2022_summary, "standardized_data/gsi_2022_summary.csv")


# write gsi_2022 to standardized_data
write_csv(gsi_2022, "standardized_data/gsi_2022.csv")
