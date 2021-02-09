# Ammitto Adapter

Adapter to fetch and process data for amiitto gem. This adapter is designed to handle all data source repositories of ammitto.

# How it works

 * Clone this repository and run `ruby adapter.rb`
 * This will search for respective data repos(e.g. un-data,eu-data) in corresponding parent directory. 
(For example: If adapter is placed in a directory called `/home/xxx/adapter` then data repo to update should be at `/home/xxx/`)
 * This will fetch the data from corresponding sources, download them and save at data repo's `downloaded` directory and then process the data and store the processed data into `processed` directory of corresponding data repo.  



 
 