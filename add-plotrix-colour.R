library(tidyverse)
library(plotrix)
df <- read_csv("https://www.dropbox.com/s/km9r94fz2ixknc7/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv?dl=1")
df_with_plotrix_colour <- df %>% 
  rowwise() %>% 
  mutate(synth_plotrixcolour = 
           if_else(synth_75sqisvalid == 0, "", color.id(synth_75imaveragecolour)[1]))
# Note, "' gets converted to "NA" by write_csv() by default
write_csv(df_with_plotrix_colour, "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-metadata.csv", na="")