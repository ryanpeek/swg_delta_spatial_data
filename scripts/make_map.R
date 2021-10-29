# make static map

library(sf)
library(dplyr)
library(mapview)
library(tmap)
library(tmaptools)
library(urbnmapr) # https://github.com/UrbanInstitute/urbnmapr
# install with: devtools::install_github("UrbanInstitute/urbnmapr")

mapviewOptions(fgb=FALSE) # turn off this to save data easily
mapviewOptions(platform = "mapdeck") # for quick rendering

# Check layers in Data ----------------------------------------------------

geopackage <- "data/ca_river_delta_spatial_data.gpkg"
st_layers(geopackage) # shows layers in geopackage

# Make a Static Map -------------------------------------------------------

# get CA
ca <- urbnmapr::get_urbn_map(map="states", sf=TRUE) %>%
  filter(state_abbv == "CA")
# warning is ok about old-style crs

# get CA county boundary
ca_co <- urbnmapr::get_urbn_map(map = "counties", sf=TRUE) %>%
  filter(state_abbv == "CA")

# get rivers
rivers <- st_read(geopackage, layer = "maj_rivers_ca")

# Make Simple Basemap -----------------------------------------------------

# first make CA map with no border
(map_ca <- tm_shape(ca) + tm_polygons(border.alpha = 0.3) +
   tm_shape(ca_co) + tm_polygons(border.col = "gray10",col = NA, border.alpha = 0.3) +
   tm_shape(rivers) + tm_lines(col="darkblue", lwd = .7, alpha = 0.8) +
   tm_layout(frame=FALSE) +
    tm_compass(type = "arrow", size = 2,
               position = c(0.1,0.18)) +
    tm_scale_bar(breaks = c(0, 100, 200),
                 text.size = 0.6,
                 position = c(0.12, 0.1))
)

tmap::tmap_save(tm = map_ca,
                filename = "maps/state_riv_map.jpg", width = 8, height = 11, units = "in", dpi = 300)



# Make Specific Delta Region Map with Baselayer ---------------------------

delta <- st_read(geopackage, layer = "legal_delta")
yolo <- st_read(geopackage, layer = "yolo_bypass")
plot(delta$geom)
plot(yolo$geom, add=T, col = "blue")

# get raster baselayer data
gm_osm <- read_osm(delta, type = "esri-topo", raster=TRUE)
# can save this out as an RDS file to save time if need be
tmap_options(max.raster = c(plot=1e6, view=1e6))



(yolo_map <-
    # baselayer
    tm_shape(gm_osm) + tm_rgb() +
    tm_shape(yolo) +
    tm_polygons(border.col="cyan4", alpha = 0, lwd=3) +
    tm_shape(delta) +
    tm_polygons(border.col = "darkblue", alpha=0, lwd=3) +

    # layout
    tm_layout(
      frame = FALSE,
      attr.outside = FALSE,
    tm_compass(type = "4star", position = c(0.55, 0.05), text.size = 0.5) +
    tm_scale_bar(position = c(0.45,0.05), breaks = c(0,2.5,5,10),
                 text.size = 0.6)))

tmap::tmap_save(tm = yolo_map,
                filename = "maps/yolo_map.jpg", width = 8, height = 11, units = "in", dpi = 300)
