# Ammitto Adapter

Legacy adapter to fetch and process data for the earlier Ammitto repository layout.

This tool discovers sibling repositories named `un-data`, `eu-data`,
`us-govt-data`, and `wb-data`. It does not discover the current `data-*`
repositories or produce the current gem's harmonized knowledge graph.
For the current pipeline, follow the
[ammitto gem documentation](https://github.com/ammitto/ammitto) and the
[aggregated data repository](https://github.com/ammitto/data).

# How it works

 * Clone this repository.
 * Install the dependencies listed in `Gemfile` first with `bundle install`,
   then use `bundle exec ruby adapter.rb`.
 * This will search for respective data repos(e.g. un-data,eu-data) in corresponding parent directory. 
(For example: If adapter is placed in a directory called `/home/xxx/adapter` then data repo to update should be at `/home/xxx/`)
 * This will fetch the data from corresponding sources, download them and save at data repo's `downloaded` directory and then process the data and store the processed data into `processed` directory of corresponding data repo.  

## Regression checks

The offline regression check uses Ruby 3.3 and its own dependency bundle,
separate from the legacy application's lockfile:

```sh
BUNDLE_GEMFILE=.github/validation.Gemfile bundle install
BUNDLE_GEMFILE=.github/validation.Gemfile bundle exec ruby test/us_govt_extractor_test.rb
```

The check uses local XML fixtures and temporary directories; it does not
fetch authority data.
