library(tidyverse)
library(ggalt)
roland_f_2019_2020_narrow_dataset <- read_csv("https://media.githubusercontent.com/media/rtanglao/rt-flickr-sqlite-csv/main/LARGE_CSV_FILES/pacific-yyyy-mm-dd-2020-2019-roland-flickr-datetaken-synth_75sqisvalid-synth_plotrixcolour_unixtimedt.csv")
second_of_day_roland_f_2019_2020_narrow_dataset <- 
  roland_f_2019_2020_narrow_dataset %>% 
  rowwise() %>% 
  mutate(second_of_day = 
           hour(as_datetime(unixtime_dt, tz="America/Vancouver")) * 3600 +
           minute(as_datetime(unixtime_dt, tz="America/Vancouver")) * 60 +
           second(as_datetime(unixtime_dt, tz="America/Vancouver")))
second_of_day_roland_flickr_20192020_average_colour_plot_colors_factor <- ggplot(second_of_day_roland_f_2019_2020_narrow_dataset,  aes(second_of_day,synth_plotrixcolour))
geomencircle_roland_flickr_20192020_average_colour_plot_colors_plot <- 
  second_of_day_roland_flickr_20192020_average_colour_plot_colors_factor +
  geom_encircle(aes(group=synth_plotrixcolour,
                    colour=I(synth_plotrixcolour),
                    fill=I(synth_plotrixcolour))) + 
  geom_point(aes(colour=I(synth_plotrixcolour))) +
  facet_wrap(~ pacific_ymd) +
  theme_void() +
  theme(
    strip.background = element_blank(),
    strip.text.x = element_blank()
  )  
