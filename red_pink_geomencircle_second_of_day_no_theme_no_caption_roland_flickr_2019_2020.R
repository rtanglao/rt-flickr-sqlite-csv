library(tidyverse)
library(ggalt)
library(lubridate)
roland_f_2019_2020_narrow_dataset <- read_csv("LARGE_CSV_FILES/pacific-yyyy-mm-dd-2020-2019-roland-flickr-datetaken-synth_75sqisvalid-synth_plotrixcolour_unixtimedt.csv")
red_pink_roland_f_2019_2020_narrow_dataset <- roland_f_2019_2020_narrow_dataset %>% 
  filter(grepl('red|pink', synth_plotrixcolour))
red_pink_second_of_day_roland_f_2019_2020_narrow_dataset <- 
  red_pink_roland_f_2019_2020_narrow_dataset %>% 
  rowwise() %>% 
  mutate(second_of_day = 
           hour(as_datetime(unixtime_dt, tz="America/Vancouver")) * 3600 +
           minute(as_datetime(unixtime_dt, tz="America/Vancouver")) * 60 +
           second(as_datetime(unixtime_dt, tz="America/Vancouver")))
red_pink_second_of_day_roland_flickr_20192020_average_colour_plot_colours_factor <- ggplot(red_pink_second_of_day_roland_f_2019_2020_narrow_dataset,  aes(second_of_day,synth_plotrixcolour))
red_pink_geomencircle_roland_flickr_20192020_average_colour_plot_colours_plot <- 
  red_pink_second_of_day_roland_flickr_20192020_average_colour_plot_colours_factor +
  geom_encircle(aes(group=synth_plotrixcolour,
                    colour=I(synth_plotrixcolour),
                    fill=I(synth_plotrixcolour))) + 
  geom_point(aes(colour=I(synth_plotrixcolour))) +
  facet_wrap(~ pacific_ymd, scales = "free") +
  theme_void() +
  theme(
    strip.background = element_blank(),
    strip.text.x = element_blank()
  )  
