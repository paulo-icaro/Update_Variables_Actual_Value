# =========================================== #
# === CURRENT TO ACTUAL - VALUES UPDATING === #
# =========================================== #

# --- Script by: Paulo Icaro --- #

# ================= #
# === Libraries === #
# ================= #
library(lubridate)
source('https://raw.githubusercontent.com/paulo-icaro/Ipeadata_API/refs/heads/main/ipeadata_query.R')                                        # Ipeadata Query Function
source('https://raw.githubusercontent.com/paulo-icaro/Variables_Frequency_Transforming/refs/heads/main/variables_frequency_transforming.R')  # Variable Frequency Transforming Function


# ====================== #
# === Current Values === #
# ====================== #
value_updating = function(series, variables, base_period = 'most_recent', frequency = 'monthly', start, end = year(Sys.Date())){
  
  # --- Extract Series --- #
  price_index =  ipeadata_query('PRECOS12_IPCA12', 'ipca', seq(from = start, to = end, by = 1))
  price_index = price_index %>% mutate(data = as.Date(data))
  
  
  # --- Base Price Index --- #
  if(base_period == 'most_recent'){
    base_index = last(price_index$ipca)
  } else {
    base_index = price_index |> filter(data == paste0(base_period,'-01')) |> pull(ipca)
  }
  
  
  # --- Adjusting Price Index According to Reference Date --- #
  price_index = price_index |> mutate(ipca_adj = ipca/base_index*100)
  
  
  # --- Adjusting Price Index Frequency --- #
  price_index_freq_adj = cumulative_transform(transform_type = 'periodo_final', frequency = frequency, dataset = price_index)
  
  
  # --- Current Series Value --- #
  adjusted_series = 
    series |> 
    inner_join(x = price_index, by = 'data') |>
    mutate(across(all_of(variables), ~ .x/ipca_adj * 100))
  
  return(adjusted_series)
}