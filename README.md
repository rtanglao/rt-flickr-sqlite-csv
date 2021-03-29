# rt-flickr-sqlite-csv
flickr api data in CSV and SQLite

## 28march2021 how to get average colour using imagemagick version 7

* `ggrep` because of OS X BSD  ridiculousness :-)

```bash
magick convert  2020-12-31-01-12-41-50781630447-IMG_4248.jpg \
-resize 1x1 txt:- | ggrep -Po "#[[:xdigit:]]{6}
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
