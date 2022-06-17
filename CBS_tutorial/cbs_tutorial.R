
#  Background -------------------------------------------------------------

# This is the "Catography" example instructions from CBS. It explains hwo to access CBS
# data and overlay on gis data

# https://www.cbs.nl/en-gb/our-services/open-data/statline-as-open-data/cartography


# Load packages -----------------------------------------------------------


library(cbsodataR)
library(tidyverse)
library(sf)



#  Inspect metadata -------------------------------------------------------

# Find out which columns are available
metadata <- cbs_get_meta("83765NED")
print(metadata$DataProperties$Key)



# Get data ----------------------------------------------------------------

data <- cbs_get_data("83765NED",
                      select=c("WijkenEnBuurten","GeboorteRelatief_25")) %>%
  mutate(WijkenEnBuurten = str_trim(WijkenEnBuurten),
         births = GeboorteRelatief_25) %>%
  identity()


# Retrieve data with municipal boundaries from PDOK
municipalBoundaries <- st_read("https://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_gemeente_2022_gegeneraliseerd&outputFormat=json")


# Join datasets

joined_data <- municipalBoundaries %>%
  left_join(data, by = c("statcode" = "WijkenEnBuurten"))

# Create the map

joined_data %>%
  ggplot() +
  geom_sf(aes(fill = births)) +
  scale_fill_viridis_c() +
  labs(title = "Births per 1000 residents 2017", fill ="") +
  theme_void()
