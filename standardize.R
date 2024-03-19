library(tidyverse)
library(here)
library(readxl)

# read in original_data
co_gsi <- read_excel("original_data/IYS2022_Coho_genetic_tissue_GCL_IYS_key_2023-08-25_ER.xlsx")|> 
  select(specimen_id, "IAgroup" = resolved_stock_id)
cu_gsi <- read_csv("original_data/IYS chum individual assignments_9.21.23.csv")
so_gsi <- read_csv("original_data/IYS sockeye individual assignments_9.21.23.csv")

# combine data
gsi_2022 <- bind_rows(so_gsi, cu_gsi, co_gsi) |> 
  select("specimen_id" = "IYS_Specimen_ID", IAgroup) |> 
  # find and replace "CanTrawl" with "Trawl" in specimen_id string
  mutate(specimen_id = str_replace(specimen_id, "CanTrawl", "Trawl"))

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
