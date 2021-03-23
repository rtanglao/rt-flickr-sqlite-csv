# rt-flickr-sqlite-csv
flickr api data in CSV and sqlite
## 22march2021 the usual bundler and ruby things
* backup-RolandsPublicPhotoMetaDataByYear.rb flattens the json file luckily there's only 1 thing that has to be flattened which is:
* `photo["description"]["_content"]` which is flattened to `photo["description_content"]`

```bash
bundle install
bundle exec ./backup-RolandsPublicPhotoMetaDataByYear.rb 2020 # output: 2020-roland-flickr-metadata.csv
bundle exec ./backup-RolandsPublicPhotoMetaDataByYear.rb 2019 # output: 2019-roland-flickr-metadata.csv
```
