################################
## habitat - kml.R
##
## This script takes gps and google gps data and
## outputs kml files of the point surrounded by a circle with a 75m radius
##
## Next step is to open kml file in google and save map as picture files in "maps"
################################

library(maptools)

write.kml <- function(ID, data, output, alt) {
    write(x = paste0("<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<kml xmlns=\'http://earth.google.com/kml/2.2\'>
<Document>
  <name>",ID,"</name>
  <description><![CDATA[]]></description>
  <Style id=\'style1\'>
    <IconStyle>
      <Icon>
        <href></href>
      </Icon>
    </IconStyle>
  </Style>
  <Style id=\'style2\'>
    <LineStyle>
      <color>73FF0000</color>
      <width>5</width>
    </LineStyle>
  </Style>
  <Camera>
    <longitude>",data$long[1],"</longitude>
    <latitude>",data$lat[1],"</latitude>
    <altitude>",alt,"</altitude>
    <heading>0</heading>
    <tilt>0</tilt>
  </Camera>
  <Placemark>
    <name>",ID,"</name>
    <description><![CDATA[<br>]]></description>
    <styleUrl>#style1</styleUrl>
    <Point>
      <coordinates>",data$long[1],",",data$lat[1],",0.000000</coordinates>
    </Point>
  </Placemark>
  <Placemark>
    <name>",ID,"</name>
    <description><![CDATA[<br>]]></description>
    <styleUrl>#style2</styleUrl>
    <LineString>
      <tessellate>1</tessellate>
      <coordinates>\n",
        paste0(paste0(apply(data[2:nrow(data), c("long","lat")], 1, paste0, collapse = ","), collapse = ",0\n "),",0\n", data[2, 'long'], ",", data[2, "lat"], ",0"),"
      </coordinates>
    </LineString>
  </Placemark>
</Document>
</kml>"), file = output)
}

## Create subfolders if they don't already exist
if(!dir.exists("./kml/")) dir.create("./kml/")
if(!dir.exists("./maps/")) dir.create("./maps/")
if(!dir.exists("./data/")) dir.create("./data/")
if(!dir.exists("./gimp/")) dir.create("./gimp/")

## Read in data
gps <- read.csv("gps.csv")

## Setup up the display 
p <- 40         # number of points in the circle
dist <- 0.075   # radius of the desired cirlce in kilometers
alt <- 225      # Altitude of 

# For each gps location, write a kml file zoomed in and with a circle outlining
# the territory The temp file consists of the first row being the center of the
# circle, and all the outer circle points following, this is passed on to the
# KML function (above)

for(i in 1:nrow(gps)) {
    ID <- gps$ID[i]
    temp <- gps[i, c("long","lat")]
    temp <- rbind(temp, gcDestination(lon = gps[i,'long'], 
                                      lat = gps[i,'lat'], 
                                      bearing = ((2:(p+1))*(360/p)-360/p), 
                                      dist = dist, dist.units = "km"))
    write.kml(ID = ID, alt = alt, data = temp, output = paste0("./kml/",ID,".kml"))
    ##plot(temp,type="l")  ## use this to verify the points
}


######################
## Maps
######################
# Open the kml files in Google Earth (drag and drop them on google Earth or use right-click Open with Google Earth
# Save the image to the 'maps' folder as the ID.jpg using File > Save > Save image, or Ctrl-Alt-S

# Optional
# To keep track of which kml files have already been saved as maps, move the 
# move kml files that have maps OR data to "finished"

library(stringr)
if(!dir.exists("./kml done/")) dir.create("./kml done/")

# Grab all kml files that have maps, but are not in the 'kml done' folder
kml <- list.files("./kml done/", pattern = ".kml$")
kml <- str_extract(kml, "[^.]*")
done <- list.files("./maps/", pattern = ".jpg$")
done <- str_extract(done, "[^.]*")
done <- done[!(done %in% kml)]

# Copy the files to the 'kml done' folder and remove them from the 'kml' folder
file.copy(paste0("./kml/",done,".kml"), 
          paste0("./kml done/"), overwrite = T)
file.remove(paste0("./kml/",done,".kml"))

######################
## GIMP
######################

# Open the maps in the Gimp and run scripts
