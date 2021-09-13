# generates
# https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/OUTPUT_GRAPHICS/flickr-roland-2019-2020-average-colour-by-the-second-scale-free.png

df_with_plotrix_colour  <- read_csv(
  "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-integer-imavgcolour-plotrixavgcolour-metadata.csv")
df_with_plotrix_colour_unixtime_dt <- df_with_plotrix_colour  %>% 
  rowwise() %>% 
  mutate(unixtime_dt = 
           if_else(synth_75sqisvalid == 0, 0, as.numeric(parse_date_time(datetaken, "%Y-%m-%d %H:%M:%s"))))
write_csv(df_with_plotrix_colour_unixtime_dt,
          "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-unixtimedt.csv", na="")
pacific_df_with_plotrix_colour_unixtime_dt <-
  df_with_plotrix_colour_unixtime_dt %>%
  mutate(pacific_ymd = format(lubridate::with_tz(parse_date_time(datetaken, "%Y-%m-%d %H:%M:%s"),
                                                 "America/Vancouver"),"%Y-%m-%d"))
p4_colors_factor <- ggplot(pacific_df_with_plotrix_colour_unixtime_dt, aes(unixtime_dt,synth_plotrixcolour))
p4 <- p4_colors_factor + geom_encircle(aes(group=synth_plotrixcolour,
                                           colour=I(synth_plotrixcolour),
                                           fill=I(synth_plotrixcolour))) + 
  geom_point(aes(colour=I(synth_plotrixcolour)))  + facet_wrap(~ pacific_ymd, scales = "free")