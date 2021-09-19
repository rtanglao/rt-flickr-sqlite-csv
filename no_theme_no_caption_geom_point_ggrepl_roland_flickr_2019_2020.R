library(tidyverse)
library(ggrepel)
roland_f_2019_2020_narrow_dataset <- read_csv("https://media.githubusercontent.com/media/rtanglao/rt-flickr-sqlite-csv/main/LARGE_CSV_FILES/pacific-yyyy-mm-dd-2020-2019-roland-flickr-datetaken-synth_75sqisvalid-synth_plotrixcolour_unixtimedt.csv")
roland_flickr_20192020_average_colour_plot_colors_factor <- ggplot(roland_f_2019_2020_narrow_dataset,  aes(unixtime_dt,synth_plotrixcolour))
ggrepel_roland_flickr_20192020_average_colour_plot_colors_plot <- roland_flickr_20192020_average_colour_plot_colors_factor +
geom_point(aes(colour=I(synth_plotrixcolour)))  + 
  geom_label_repel(aes(label = synth_plotrixcolour, colour = I(synth_plotrixcolour)),
                   vjust = "inward", hjust = "inward", parse = TRUE,
                   nudge_y = 2.5, nudge_x = -8, size = 3) +
  facet_wrap(~ pacific_ymd, scales = "free") +
  theme_void() +
  theme(
    strip.background = element_blank(),
    strip.text.x = element_blank()
  )  
