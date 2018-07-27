## Vector Data

library(sf)

shp <- 'data/cb_2016_us_county_5m'
counties <- st_read(shp, stringsAsFactors = FALSE)

plot(counties$geometry)

# create spatial dataframe with SESYNC coordinates
# sfc = simple feature column
# use CRS from counties file
sesync <- st_sfc(
    st_point(c(-76.503394, 38.976546)),
    crs = st_crs(counties))

plot(sesync) # we made a point!
class(sesync)
st_crs(counties) # get CRS

st_bbox(counties) # get extent

## Bounding box

library(dplyr)

counties_md <- counties %>%
  filter(STATEFP == '24')

names(counties_md)
dim(counties) # check dimensions before plotting
plot(counties_md) # by default plots all columns

## Grid

class(st_crs(st_bbox(counties_md)))

grid_md <- st_make_grid(counties_md, n=4) # create 4 X 4 grid of md extent
plot(grid_md)

## Plot Layers

plot(grid_md)
plot(counties_md['ALAND'], add = TRUE)
plot(sesync, col = "green", pch = 20, add = TRUE) # add = true to add layer

# st_within allows you to subset based on location
# many other functions that do lots of spatial operations
st_within(sesync, counties_md)

## Coordinate Transforms

shp <- 'data/huc250k'
huc <- st_read(shp, stringsAsFactors = F)

dim(huc)
plot(huc$geometry) # plots only the outline (not other fields)

prj <- '+proj=aea +lat_1=29.5 +lat_2=45.5 \
    +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 \
    +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 \
    +units=m +no_defs'

# check if CRS are different
st_crs(counties_md)$proj4string
st_crs(huc)$proj4string

# spatialreference.org is useful website to lok up CRS string
# look for Proj4 string

counties_md <- st_transform(
    counties_md,
    crs = prj)

huc <- st_transform(
  huc,
  crs = prj)

sesync <- st_transform(
  sesync,
  crs = prj)

plot(counties_md$geometry)
plot(huc$geometry,
     border = 'blue', add = TRUE)
plot(sesync, col = 'green',
     pch = 20, add = TRUE)

# analysis and modeling needs spdep (?)
# for Moran's I, spatial regression, etc.

## Geometric Operations

state_md <- st_union(counties_md) # remove interior county boundaries
plot(state_md)

# clip hydrological unit by maryland outline
huc_md <- st_intersection(
  huc, 
  state_md
)

plot(huc_md$geometry, border = 'blue',
     col = NA)
plot(state_md, add = TRUE)
# careful w/ attributes - they are not necessarily correct for clipped region
# properties not updated
# can update attributes with things like st_area, st_buffer, etc.

## Raster Data

library(raster)
nlcd <- raster("data/nlcd_agg.grd")
res(nlcd) # look at resolution of the dataset

## Crop

extent <- matrix(st_bbox(huc_md), nrow=2)
extent
nlcd <- crop(nlcd, extent) # crop nlcd

plot(nlcd)
plot(huc_md$geometry, col = NA, add = TRUE)

## Raster data attributes

head(nlcd@data@attributes[[1]])
class(nlcd@data@attributes[[1]])

nlcd_attr <- nlcd@data@attributes[[1]]

# create table of frequency of values
tb <- freq(nlcd)

# get list of land cover types
lc_types <- levels(nlcd_attr$Land.Cover.Class)

inMemory(nlcd) # check if raster is in memory
# sometimes temporary files are used??

## Raster math

pasture <- mask(nlcd, nlcd == 81,
    maskvalue = FALSE)

plot(pasture)

# change the cell cize
nlcd_agg <- aggregate(nlcd,
    fact = 25,   # aggregation factor, # of cells in each direction
    fun = modal) # this means use mode

plot(nlcd_agg)
freq(nlcd_agg)

## Mixing rasters and vectors: prelude

library(sp)
sesync <- as(sesync, "Spatial")
huc_md <- as(huc_md, "Spatial")
counties_md <- as(counties_md, "Spatial")

class(sesync)

## Mixing rasters and vectors

plot(nlcd)
plot(sesync, col = 'green',
     pch = 16, cex = 2, add=T)

# value of landcover at location of SESYNC
sesync_lc <- extract(nlcd, sesync)

county_nlcd <- extract(nlcd_agg,
                       counties_md[1,],
                       df=T)

# get most common landcover in each hydrological unit
modal_lc <- extract(nlcd_agg,
                    huc_md,
                    fun = modal)

modal_lc <- lc_types[modal_lc + 1]

