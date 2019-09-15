#Summary of demographics and performance for HISD District IV schools
#For Leadership ISD

library(tidyverse)
library(janitor)
library(here)
library(sf)
library(mapview)

#Data ------
#2019 accountability ratings
tea19 <- read_csv(here::here("data", "CAMPRATE.dat")) %>% 
  filter(DISTNAME == "HOUSTON ISD") %>% 
  dplyr::select(CAMPUS, CAMPNAME, DISTRICT, DISTNAME,
                GRDTYPE, GRDSPAN,
                CDALLS, C_RATING, CD1G, CD2AG, CD3G) 

#2017-2018 profile/demographics
demo19 <- read_csv(here::here("data", "CAMPPROF.dat")) %>% 
  dplyr::select(CAMPUS, CPETALLC,CPETBLAC, CPETBLAP, CPETINDC, CPETINDP, CPETASIC, CPETASIP,
                CPETHISC, CPETHISP, CPETPCIC, CPETPCIP, CPETTWOC, CPETTWOP, CPETWHIC, CPETWHIP,
                CPETECOC, CPETECOP, CPETLEPC, CPETLEPP) 

#Combine
tea19 <- left_join(tea19, demo19, by = "CAMPUS")



#Shapefiles ----
#School shapefile
wgs84 <- st_crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

schools <- sf::read_sf(here::here("data", "Current_Schools.shp")) %>% st_transform(., wgs84)

#Board district shapfile
districts <- sf::read_sf(here::here("data", "Board_March2018.shp")) %>% st_transform(., wgs84)

#Overlay and filter schools by district
hisd_schools <- st_join(schools, districts) %>% 
  filter(!is.na(NUMBER) & District_1=="HOUSTON ISD") %>% 
  dplyr::select(Match_addr, School_Nam, School_Num, School_Pri, NUMBER, NAME2, Member) %>% 
  mutate(
    CAMPUS = str_replace_all(School_Num, "'", "")
  )



#Master ----
#Add TEA data into master sf file
hisd_schools <- left_join(hisd_schools, tea19, by="CAMPUS")

#export
saveRDS(hisd_schools, file=here::here("getStarted.rds"))


