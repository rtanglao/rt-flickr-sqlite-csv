# rt-flickr-sqlite-csv
flickr api data in CSV and SQLite

## 13september2021

* running [theme-void-create-flickr-roland-2019-2020-average-colour-by-the-second-scale-free.R](https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/theme-void-create-flickr-roland-2019-2020-average-colour-by-the-second-scale-free.R) creates [8000px-flickr-roland-2019-2020-average-colour-by-the-second-scale-free.png](https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/OUTPUT_GRAPHICS/theme-void-8000px-flickr-roland-2019-2020-average-colour-by-the-second-scale-free.png)
## 13september2021 write a smaller dataset

* 1\. write a CSV file with pacific time zone yyyy-mm-dd
```r
write_csv(pacific_df_with_plotrix_colour_unixtime_dt,
"/Users/roland/Documents/GIT/rt-flickr-sqlite-csv/LARGE_CSV_FILES/pacific-yyyy-mm-dd-2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-unixtimedt.csv",
na="")
```
* 2\. write a CSV file with only the columns we need
```bash
mlr --csv cut -f datetaken,synth_plotrixcolour,synth_75sqisvalid,pacific_ymd \                      
pacific-yyyy-mm-dd-2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-unixtimedt.csv |\
grep -v "UTC,0," > pacific-yyyy-mm-dd-2020-2019-roland-flickr-datetaken-synth_75sqisvalid-synth_plotrixcolour.csv
```
* 3\. ooops forgot unixtime_dt
```bash
mlr --csv cut -f datetaken,synth_plotrixcolour,synth_75sqisvalid,unixtime_dt,pacific_ymd\                      
 pacific-yyyy-mm-dd-2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-unixtimedt.csv |\
grep -v "UTC,0," > pacific-yyyy-mm-dd-2020-2019-roland-flickr-datetaken-synth_75sqisvalid-synth_plotrixcolour_unixtimedt.csv
```

## 09may2021 convert to PNG via RGB

and the PNG file looks like the previous one, but it only has 657 colours!

```bash
< 2020-and-2019-roland-flickr-imagemagick-r-plotrix-average-colours.csv | \
tail -n +2 | head -n 49284 | \
xxd -r -p >roland-2020-and-2019-r-colours-222x222.rgb 
magick -size 222x222 -depth 8 roland-2020-and-2019-r-colours-222x222.rgb \
roland-2020-and-2019-r-colours-222x222.png
```

## 09may2021 get all colours as integers using R's 657 colours

```R
getnumericColour <-
  function(colourname) {
    if (colourname == "") {
      return(as.hexmode(0))
    }
    colour_matrix = col2rgb(colourname)
    return(as.hexmode(
      as.numeric(colour_matrix[1, 1]) * 65536 +
        as.numeric(colour_matrix[2, 1]) * 256 +
        as.numeric(colour_matrix[3, 1])
    ))
  }
df_with_integer_plotrix_colour <- df_with_plotrix_colour %>%
  rowwise() %>%
  mutate(synth_intplotrixcolour =
           if_else(synth_75imaveragecolour == "<NA>", as.hexmode(0), getnumericColour(synth_plotrixcolour)))
write_csv(df_with_integer_plotrix_colour, "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-integer-imavgcolour-plotrixavgcolour-metadata.csv", na="")
```
 and then in the shell:
```bash
mlr --csv cut -f synth_intplotrixcolour,synth_75sqisvalid \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-integer-imavgcolour-plotrixavgcolour-metadata.csv \
| grep -v "0," \
> 2020-and-2019-roland-flickr-imagemagick-r-plotrix-average-colours.csv
```

## 21april2021 convert the 657 colours back to integer values

```R
> getnumericColour <-
+     function(colorname) {
+         colour_matrix=col2rgb(colorname)
+         return(as.numeric(colour_matrix[1,1]) * 65536 +
+                    as.numeric(colour_matrix[2,1]) * 256 +
+                    as.numeric(colour_matrix[3,1]))
+     }
> getnumericColour("violetred")
[1] 13639824
> getnumericColour("yellow2")
[1] 15658496
> as.hexmode(getnumericColour("yellow2"))
[1] "eeee00"
> str(as.hexmode(getnumericColour("yellow2")))
 'hexmode' int eeee00
```

## 18april2021 how to add the 657 built in R colors to the flickr dataset
* the dataset withe R colors is on dropbox:
https://www.dropbox.com/s/sfooyejehxus7rq/2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-metadata.csv?dl=0
* need `rowwise()` otherwise it computes the color of all the rows not row by row!
```R
library(tidyverse)
library(plotrix)
df <- read_csv(\
"https://www.dropbox.com/s/km9r94fz2ixknc7/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv?dl=1")
df_with_plotrix_colour <- df %>% 
  rowwise() %>% 
  mutate(synth_plotrixcolour = 
           if_else(synth_75sqisvalid == 0, "", color.id(synth_75imaveragecolour)[1]))
# Note, "' gets converted to "NA" by write_csv() by default
write_csv(df_with_plotrix_colour, \
"/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imavgcolour-plotrixavgcolour-metadata.csv"\
, na="")
```
## 18april2021 unclean data came from me forgetting to filter out the 1 row without average colour!
* tl;dr `2020-and-2019-roland-flickr-imagemagick-average-colours.csv` has 1 row without average colour because I forgot to filter it out
* WRONG i.e. what I actually did :-) :
```bash
mlr --csv cut -f synth_75imaveragecolour,synth_75sqisvalid \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv\
> 2020-and-2019-roland-flickr-imagemagick-average-colours.csv
```
* RIGHT filter out the row without average colour (untested but should work) :
```bash
mlr --csv cut -f synth_75imaveragecolour,synth_75sqisvalid \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv |\
grep -v ",0" \
> 2020-and-2019-roland-flickr-imagemagick-average-colours.csv
```
## 12april2021 figured it out, it's my non clean data :-)
* remove the one row i.e. row 19907 without a thumbnail and therefore without an average colour and then go from there!
```bash
grep  "#" 2020-and-2019-roland-flickr-imagemagick-average-colours.txt \
> missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.txt
head -n 49284 missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.txt \
>49284-missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.txt
xxd -l 49284 -u -r -p \
49284-missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.txt \
> 49284-missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.rgb
magick -depth 8 -size 222x222 \
49284-missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.rgb \
49284-missing-thumbnail-with-missing-avgcolour-removed-2020-and-2019-roland-flickr-imagemagick-average-colours.png
```

## 12april2021 probably not an imagemagick but a bug in my data aka i forgot that the average colour is missing for 1 row!

* row 19907 doesn't have an average colour because flickr doesn't have a thumbnail!
```bash
% grep -C 3 -vn "#" 1st-49284-2020-2019-roland-flickr-average-colours.txt 
19904-#333436
19905-#AAABAD
19906-#AFAFAF
19907:
19908-#A7A9AA
19909-#B7B8B7
19910-#B5B6B6
```

## 11april2021 i really need those two* * three = 6 extra bytes but i don't understand why!
* Again :-) I don't understand why since 222*222 = 49,284
* Perhaps 64 bit boundary? Or little endian? big endian?
```bash
% { printf "P6\n%d %d\n255\n" 222 222 ; cat 1st-49284-2020-2019-roland-flickr-average-colours.rgb} \
| magick  - image88.png
magick: unable to read image data `/var/folders/h0/m31kq8415wb50xg_7kwk06h40000gn/T/magick-2mCuD6a8H66a7qb5_WpeXHJ3uph3P9pv' @ error/pnm.c/ReadPNMImage/1442.
% { printf "P6\n%d %d\n255\n" 222 222 ; cat 1st-49286-2020-2019-roland-flickr-average-colours.rgb} \
| magick  - image88.png
%
```
## 10april2021 magick and magick convert work on macOS but don't work on Ubuntu 20.04 Version: ImageMagick 7.0.11-6 Q16 x86_64 2021-04-03  convert works on both
* Maybe I built imagemagick 7 incorrectly on ubuntu 20.04?!?
* The following does work on macOS catalina: `Version: ImageMagick 7.0.11-6 Q16 x86_64 2021-04-03 https://imagemagick.org
`
* `convert` from imagemagick version 6 works:
```bash
{ printf "P6\n%d %d\n255\n" 222 222 ; cat no-filetype-2020-and-2019-roland-flickr-imagemagick-average-colours; } \
| convert - image88.png
```
* `magick convert` from im7 does NOT work:
```bash
 printf "P6\n%d %d\n255\n" 222 222 ; cat no-filetype-2020-and-2019-roland-flickr-imagemagick-average-colours; } \
 | magick convert - image88.png
 ```
 * `magick` from im7 does NOT work:
 ```bash
  printf "P6\n%d %d\n255\n" 222 222 ; cat no-filetype-2020-and-2019-roland-flickr-imagemagick-average-colours; } \
  | magick  - image88.png
```
## 10april2021 two * three = 6 extra bytes fixes it, i am not sure why?!?!

* maybe it's a 64 bit issue? endian issue?
* 222 * 222 = 49284. Not sure why we need two extra 3 byte lines
```bash
head -n 49286 2020-and-2019-roland-flickr-imagemagick-average-colours.txt \
> 1st-49286-2020-2019-roland-flickr-average-colours.txt
xxd -r -p 1st-49286-2020-2019-roland-flickr-average-colours.txt \
1st-49286-2020-2019-roland-flickr-average-colours.rgb
convert -size 222x222 -depth 8 1st-49286-2020-2019-roland-flickr-average-colours.rgb \
image88.png
```


# 10april2021 missing two * three = 6 bytes in the rgb file?!?

```bash
convert result.png result.rgb
hexdump 1st-49284-2020-2019-roland-flickr-average-colours.rgb \
> 1st-49284-2020-2019-roland-flickr-average-colours.hexdump
hexdump result.rgb > result.hexdump
diff 1st-49284-2020-2019-roland-flickr-average-colours.hexdump result.hexdump
9241,9242c9241,9242
< 0024180 1312 1019 120f 140b 004a               
< 0024189
---
> 0024180 1312 1019 120f 140b 694a aa83          
> 002418c
tail -3 1st-49284-2020-2019-roland-flickr-average-colours.txt
#121319
#100F12
#0B144A

```
## 06april2021 another photoshop-less solution using printf to add a header and convert to ppm. Then use magick to convert to png

```bash
{ printf "P6\n%d %d\n255\n" 222 222 ; cat no-filetype-2020-and-2019-roland-flickr-imagemagick-average-colours; } > result.ppm
magick result.ppm result.png
```

## 05april2021 i think i figured out a photoshop-less solution
```bash
 ffmpeg -f rawvideo -pixel_format rgb24 -video_size 222x222 \
 -i 2020-and-2019-roland-flickr-imagemagick-average-colours.raw -frames:v 1 output.png
 mv output.png ffmpeg-2020-and-2019-roland-flick-average-colour-output.png
 ```
## 05april2021 still not sure why imagemagick doesn't work, maybe because the header is missing or maybe because it doesn't end with '.raw'?
* add the header as per this stack overflow question, [Converting raw images without headers](https://stackoverflow.com/questions/62602215/converting-raw-images-without-headers)?
```bash
{ printf "P6\n%d %d\n255\n" WIDTH HEIGHT ; cat YOURFILE; } > result.ppm
```
* or use `ffmpeg` as per this stack overflow question, [Convert raw RGB32 file to JPEG or PNG using FFmpeg](https://stackoverflow.com/questions/46310408/convert-raw-rgb32-file-to-jpeg-or-png-using-ffmpeg)?
```bash
ffmpeg -f rawvideo -pixel_format rgba -video_size 320x240 -i input.raw output.png #i would use rgb instead of rgba
```

## 05april2021 the file has to be called .raw to be opened in photoshop in interleaved mode

* renamed `2020-and-2019-roland-flickr-imagemagick-average-colours.rgb` to:
`2020-and-2019-roland-flickr-imagemagick-average-colours.raw` and opened in photoshop in interleaved mode, 3 channels, 222x222pixels and it worked!
* here is the PNG which worked: https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/THUMBS_75X75/interlaced-2020-and-2019-roland-flickr-imagemagick-average-colours.png
* if you select non interleaved mode, then it doesn't work but you get glorious glitch art: https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/THUMBS_75X75/2020-and-2019-roland-flickr-imagemagick-average-colours.png

## 03april2021 hilariously gnuplot works

* see http://gnuplot.sourceforge.net/demo_4.4/image.1.gnu which is an example from: http://gnuplot.sourceforge.net/demo_4.4/image.html

```
plot '2020-and-2019-roland-flickr-imagemagick-average-colours.rgb' binary array=222x222 flipy format='%uchar' with rgbimage
```

output: https://github.com/rtanglao/rt-flickr-sqlite-csv/blob/main/THUMBS_75X75/gnuplot-2020-and-2019.png

## 03april2021 create file of colours and then raw file and then png

* 1\. remove the one bad file which has `synth_75sqisvalid` set to `0` aka `false`
```bash
mlr --csv cut -f synth_75imaveragecolour,synth_75sqisvalid \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv\
| grep -v ",0" | wc -l
49549
mlr --csv cut -f synth_75imaveragecolour,synth_75sqisvalid \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv\
> 2020-and-2019-roland-flickr-imagemagick-average-colours.csv
mlr --csv cut -f synth_75imaveragecolour \
>  2020-and-2019-roland-flickr-imagemagick-average-colours.csv\
>  | tail -n +2 >2020-and-2019-roland-flickr-imagemagick-average-colours.txt
```
* 2\. create raw file
```bash
#xxd -r -p 2020-and-2019-roland-flickr-imagemagick-average-colours.txt \
2020-and-2019-roland-flickr-imagemagick-average-colours.rgb
# 222 x 222 = 49284
xxd -l 49284 -u -r -p \
2020-and-2019-roland-flickr-imagemagick-average-colours.txt 2020-and-2019-roland-flickr-imagemagick-average-colours.rgb
```
* 3\. create png
* square root of 49549 is approximately 222
```bash
magick convert -depth 8  -size 222x222 2020-and-2019-roland-flickr-imagemagick-average-colours.rgb\
 2020-and-2019-roland-flickr-imagemagick-average-colours.png
```
* fails on ubuntu 20.04 with convert and on macOS catalina with magick:

```bash
convert -size 222x222 -depth 8 RGB:2020-and-2019-roland-flickr-imagemagick-average-colours.rgb image.png
convert-im6.q16: unexpected end-of-file `2020-and-2019-roland-flickr-imagemagick-average-colours.rgb': No such file or directory @ error/rgb.c/ReadRGBImage/242.
convert-im6.q16: no images defined `image.png' @ error/convert.c/ConvertImageCommand/3258.
```

## 03april2021 imagemagick average colour worked?!?

```bash
roland@Rolands-MacBook-Air THUMBS_75X75 % bundle exec ../get-filename-imagemagick-average-colour-from-75x75thumbnail.rb \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-filename-imagemagick-avg-colour-metadata.csv
```

## 03april2021 current plan
* I don't trust myself :-)  to take the 100% care needed to get `csvjoin` to work, it's easy to mess up
* so i will add the column from ruby and in fact have multiple columns
    * synth_75sqfilename (the filename of the 75x75 thumbnail)
    * synth_75imaveragecolour (average colour by resizing to 1x1 in imagemagick)
    * synth_75sqisvalid (in case the thumbnail is not a valid jpeg or png), 1 = valid, 0 = invalid (there's only 1 invalid 75x75px thumbnail from all 45000 2019-2020 photos

## 03april2021 csvjoin does add columns like i want

```bash
roland@Rolands-MacBook-Air THUMBS_75X75 % cat testcsv.csv 
column1
samplecolumn1value
roland@Rolands-MacBook-Air THUMBS_75X75 % cat column2.csv 
column2
samplecolumn2value
roland@Rolands-MacBook-Air THUMBS_75X75 % csvjoin testcsv.csv column2.csv
column1,column2
samplecolumn1value,samplecolumn2value
```

## 03april20201 forgot about csvkit

* https://github.com/wireservice/csvkit
* from [unix stackexchange](https://unix.stackexchange.com/questions/293775/merging-contents-of-multiple-csv-files-into-single-csv-file): 
```bash
csvstack *.csv  > out.csv
``` 
* and another example from unix stackexchange: https://superuser.com/questions/26834/how-to-join-two-csv-files/851612
```bash
csvjoin -c email id_email.csv email_name.csv
```
or
```bash
csvjoin -c 2,1 id_email.csv email_name.csv
```
## 03april2021 how to fix missing photo?
* maybe just add the column to the csv file and then for a missing or broken photo, just add set the average colour to 
`""`,instead of for example `"#123456"`

## 03april2021 missing photo with id: 49822659318  on the flickr server

```
photo:49822659318, title:DSC_7954 url:https://live.staticflickr.com/65535/49822659318_9df1956f71_s.jpg filename:2020-04-26-17-05-39-49822659318-DSC_7954.jpg
D, [2021-04-03T00:06:30.682553 #55060] DEBUG -- : magick convert "2020-04-26-17-05-39-49822659318-DSC_7954.jpg" -resize 1x1 txt:- | ggrep -Po "#[[:xdigit:]]{6}"
D, [2021-04-03T00:06:30.710046 #55060] DEBUG -- : convert: insufficient image data in file `2020-04-26-17-05-39-49822659318-DSC_7954.jpg' @ error/jpeg.c/ReadJPEGImage_/1104.
```

## 02april2021 after some regular expression fun and filenames with question marks have to be in double quotation marks

* key ruby statements:
    * when shelling out filename has to have quotation marks around because of `?` and `!`, i.e. `convert \"%s\"`
    * also when shelling out `$` has to be escaped with a `\` so use `gsub` i.e. `filename.gsub(/\$/, '\$'))`
```ruby
 #filename has to have quotation marks around it
 magickimp = sprintf("magick convert \"%s\" -resize 1x1 txt:- | ggrep -Po \"#[[:xdigit:]]{6}\"",
    filename.gsub(/\$/, '\$')) # to convert dollar sign to \$
 ```

```bash
bundle exec ../get-imagemagick-average-colour-from-75x75thumbnail.rb \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv\
>imagemagick.average-colour-2020-and2019-roland-flickr-metadata.txt \
2> stderr.imagemagick.average-colour-2020-and2019-roland-flickr-metadata.tx
```
## 02april2021 using open3 to call imagemagick

### 2nd try which is cleaner

```ruby
irb(main):036:0> stdout, stderr, status = Open3.capture3(magickimp)
=> ["#58473A\n", "", #<Process::Status: pid 44198 exit 0>]
irb(main):037:1* if status.success?
irb(main):038:1*   puts stdout
irb(main):039:1* else
irb(main):040:1*   abort 'error: could not execute command'
irb(main):041:0> end
irb(main):042:0* 
#58473A
=> nil

```
### first try
```ruby
 magickimp = "magick convert  2020-12-31-01-12-41-50781630447-IMG_4248.jpg \
irb(main):025:0" -resize 1x1 txt:- | ggrep -Po \"#[[:xdigit:]]{6}\""
=> "magick convert  2020-12-31-01-12-41-50781630447-IMG_4248.jpg -resize 1x1 txt:- | ggrep -Po \"#[[:xdigi...
irb(main):026:1*   Open3.popen2e(magickimp) do |stdin, stdout_stderr, wait_thread|
irb(main):027:2*     Thread.new do
irb(main):028:2*       stdout_stderr.each {|l| puts l }
irb(main):029:1*     end
irb(main):030:1*     stdin.close
irb(main):031:1*     wait_thread.value
irb(main):032:0>   end
#58473A
```

## 29march2021 use daff merge to merge in a CSV of average colours?

* [daff](https://github.com/paulfitz/daff) might be better than `mlr` in this case!
* also check out xsv

## 28march2021 how to get average colour using imagemagick version 7

* `ggrep` because of OS X BSD  ridiculousness :-)

```zsh
magick convert  2020-12-31-01-12-41-50781630447-IMG_4248.jpg \
-resize 1x1 txt:- | ggrep -Po "#[[:xdigit:]]{6}
#58473A
```
## 28march2021 how to scramble an image

* use this on the average colour image?!?
    * https://dahtah.github.io/imager/unshuffle.html

## 28march2021 R code to map a colour to one of the R colour_names

* from http://rolandtanglao.com/2015/04/28/p2-closest-color-in-r-using-plotrix/ 

```r
> color.id("#ffff00")[1]
[1] "yellow"
```

* see also some useful rgb manipulation functions at: https://stackoverflow.com/questions/41209395/from-hex-color-code-or-rgb-to-color-name-using-r?noredirect=1&lq=1



## 28march2021 how i backed up the photos
```bash
 1129  bundle exec ../backup75x75.rb "https://www.dropbox.com/s/llkaiznbfpm85lt/2020-and-2019-roland-flickr-metadata.csv?dl=1" 2>stderr.txt
 1131  bundle exec ../backup75x75.rb "https://www.dropbox.com/s/llkaiznbfpm85lt/2020-and-2019-roland-flickr-metadata.csv?dl=1" 2>28march2021-2nd-run-stderr.txt
 1137  bundle exec ../backup75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-3rd-run-file-url-stderr.txt
 1138  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-4th-run-file-not-url-stderr.txt
 1140  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-4th-run-file-not-url-stderr.txt
 1141  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-4th-run-file-not-url-stderr.txt
 1142  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-4th-run-file-not-url-stderr.txt
 1145  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-5th-run-quotequote-file-not-url-stderr.txt
 1146  bundle exec ../backup-from-metadata-file-75x75.rb "/Users/roland/Documents/GIT/files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv" 2>28march2021-6th-run-quotequote-file-not-url-stderr.txt
 ```

## 28march2021 wordwrap/end of line issues, i took less photos than  i thought :-)

* 2.9 times as many photos in 2020 compared to 2019 (36911/12638 = 2.9)

```bash
roland@Rolands-MacBook-Air THUMBS_75X75 % mlr --csv cut -f id,datetaken,url_sq \
../../files_too_big_for_github_rt-flickr-sqlite-csv/2020-and-2019-roland-flickr-metadata.csv > /tmp/url_sq.txt
roland@Rolands-MacBook-Air THUMBS_75X75 % grep 2020- /tmp/url_sq.txt| wc -l
36911
roland@Rolands-MacBook-Air THUMBS_75X75 % grep 2019- /tmp/url_sq.txt| wc -l
12638
```

## 26march2021 make sqlite file from 2020-and-2019-roland-flickr-metadata.csv

```bash
csvs-to-sqlite 2020-and-2019-roland-flickr-metadata.csv -dt datetaken -dt dateupload\
-dt lastupdate one-table-roland2019-2020.db
```

## 26march2021 make 1 CSV file with both 2019 and 2020

`tail -n +2` outputs the entire file starting with line 2; skip the first line which is the CSVheader line

```bash
cp 2019-roland-flickr-metadata.csv 2020-and-2019-roland-flickr-metadata.csv
tail -n +2 2020-roland-flickr-metadata.csv >> 2020-and-2019-roland-flickr-metadata.csv
```
## 24march2021 moved the two table version SQLite file (one table for 2019, one for 2020) to dropbox because at 67M it's too large for github

* here is the home of the file: https://www.dropbox.com/s/6j10e2vohp2j5kf/roland2019-2020.db?dl=0
* I think a 1 table version that includes 2019 and 2020 in 1 table instead of two is probably better? so making that next

## 23march2021 creating a two table SQLite database using Simon Willion's csvs-to-sqlite

* one table for `2019-roland-flickr-metadata.csv` and one table for `2020-roland-flickr-metadata.csv`
 
```bash
csvs-to-sqlite *.csv -dt datetaken -dt dateupload -dt lastupdate roland2019-2020.db
```
## 22march2021 the usual bundler and ruby things
* You will of course need your flickr api key which you can find at:
    * `https://www.flickr.com/services/apps/by/<yourid>`
* `backup-RolandsPublicPhotoMetaDataByYear.rb` flattens the json file luckily there's only 1 thing that has to be flattened which is:
* `photo["description"]["_content"]` which is flattened to `photo["description_content"]`

```bash
bundle install
bundle exec ./backup-RolandsPublicPhotoMetaDataByYear.rb 2020 # output: 2020-roland-flickr-metadata.csv
bundle exec ./backup-RolandsPublicPhotoMetaDataByYear.rb 2019 # output: 2019-roland-flickr-metadata.csv
```
