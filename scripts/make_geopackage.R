# add data to a geopackage
# unzip spatial.zip if you want to run this, otherwise start with geopackage

library(sf)
library(dplyr)
library(here)
library(purrr)
library(glue)
library(fs)
library(mapview)
mapviewOptions(fgb=FALSE)

# List Shapefiles ---------------------------------------------------------

# list all files that end in .shp
shps <- fs::dir_ls("data/spatial", glob = "*shp")

# map over each file and read it in:
shp_ls <- map(shps, ~st_read(.x))

# transform to all the same thing
shp_ls <- map(shp_ls, ~st_transform(.x, 4326))

# check it worked
map(shp_ls, ~st_crs(.x)$epsg)

# View --------------------------------------------------------------------

# mapview(shp_ls[1]) + mapview(shp_ls[2]) + mapview(shp_ls[3])
# mapview(shp_ls[4]) + mapview(shp_ls[5]) + mapview(shp_ls[6])
# mapview(shp_ls[7]) + mapview(shp_ls[8]) + mapview(shp_ls[9])
# mapview(shp_ls[10]) + mapview(shp_ls[11]) + mapview(shp_ls[12])
# mapview(shp_ls[13]) # sac
# # US water areas and lines are 14 and 15 but too large
# # and 17 is too much too
# mapview(shp_ls[16])
# mapview(shp_ls[18])
# mapview(shp_ls[19])

# American Forks: Major mainstems for American watershed
# Analysis_areas3.shp = Cosumnes polygon
# full bay delta: Bay_delta_selection
# Fea Forks: Major mainstems for Feather
# Flood_bypasses: Yolo bypass polygon
# Flood_bypasses2: Yolo bypass extended
# Legal_Delta
# M_forks: Merced
# Mk_forks: Mokelumne
# PrimarySecondaryDelta: southern lobe of delta
# S_forks: Stanislaus
# SJ_forks: San Joaquin
# Sac_forks: Sacramento
# 17: hydro_poly_MWT (full waterbody poly)
# 18: hydro_poly_Sac_SJR (waterbody poly for sac/sjr)
# 19: t_forks: Tuolumne

# remove the layers we don't need/want right now: 14, 15, 17
names(shp_ls)
shp_ls_trim <- shp_ls[-c(14, 15, 17)]
names(shp_ls_trim)

# Write out Shapefiles --------------------------------------------------------------

names(shp_ls_trim)

# setup geopackage
gpkg_name <- "data/ca_river_delta_spatial_data.gpkg"

# write out
st_write(shp_ls_trim[[1]], dsn = gpkg_name, layer = "amer_river",
         delete_layer = TRUE, delete_dsn = TRUE)

st_write(shp_ls_trim[[4]], dsn = gpkg_name, layer = "feath_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[8]], dsn = gpkg_name, layer = "merced_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[9]], dsn = gpkg_name, layer = "moke_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[11]], dsn = gpkg_name, layer = "sjqn_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[12]], dsn = gpkg_name, layer = "stan_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[13]], dsn = gpkg_name, layer = "sac_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[16]], dsn = gpkg_name, layer = "tuo_river",
         delete_layer = TRUE)

st_write(shp_ls_trim[[2]], dsn = gpkg_name, layer = "cos_floodplain",
         delete_layer = TRUE)

st_write(shp_ls_trim[[14]], dsn = gpkg_name, layer = "yolo_bypass",
         delete_layer = TRUE)

st_write(shp_ls_trim[[6]], dsn = gpkg_name, layer = "yolosutt_bypass",
         delete_layer = TRUE)

st_write(shp_ls_trim[[7]], dsn = gpkg_name, layer = "legal_delta",
         delete_layer = TRUE)

st_write(shp_ls_trim[[10]], dsn = gpkg_name, layer = "secondarydelta",
         delete_layer = TRUE)

st_write(shp_ls_trim[[15]], dsn = gpkg_name, layer = "sacriver_poly",
         delete_layer = TRUE)

load("data/major_rivers_dissolved.rda")
rivs <- st_transform(rivs, crs=4326)

st_write(rivs, dsn = gpkg_name, layer = "maj_rivers_ca",
         delete_layer = TRUE)

# double check
st_layers(gpkg_name)



# Load RDA Files ----------------------------------------------------------

# setup geopackage
gpkg_name <- "data/ca_river_delta_spatial_data.gpkg"

# load RDA
load("data/cities_sf.rda")
mapview(cities_sf)


# write out
st_write(cities_sf, dsn = gpkg_name, layer = "ca_cities",
         delete_layer = TRUE)

st_layers(gpkg_name)
