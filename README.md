# rt-flickr-sqlite-csv
flickr api data in CSV and sqlite

## 24march2021 moved the two table version sqlite file (one table for 2019, one for 2020) to dropbox because at 60M it's too large for github

* here is the home of the file: https://www.dropbox.com/s/6j10e2vohp2j5kf/roland2019-2020.db?dl=0
* I think 1 table version that includes 2019 and 2020 is probably better? so making that next

## 23march2021 creating a database using simon willion's csvs-to-sqlite
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
