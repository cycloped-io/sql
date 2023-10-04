# SQL extraction scripts

## Description

These scripts are used to extract Wikipedia data directly from SQL dumps
located at http://dumps.wikimedia.org. Although the reference data are present
in Wikipedia article descriptions it is hard to glue all the pieces together. It
is much easier to use the specialized SQL files. They contain the data used
by real Wikipedia instance, so are most similar to the data found in articles
visible on Wikipedia by regular users.

## Scripts

* `convert_pages.rb` - used to extract data from pages.sql. This is the primary
  source of information about regular articles, categories, templates, etc.
  The SQL contains the internal ids of the articles and their titles.
* `convert_category_links.rb` - used to extract links between articles and
  categories as well as between child/parent categories
* `convert_langlinks.rb` - used to extract article links to different Wikipedia
  editions
* `convert_templates.rb` - used to extract article template inclusions
* `convert_redirects.rb` - used to extract redirection links for articles and
  categories
* `convert_links.rb` - used to extract links between articles
* `parse_sql.rb` - test script for SQL parsing
* `content_offset.rl` - source code for offset computation in XML dump
  (implemented in C for fast execution)

### Download

`utils/download.rb` is used to automatically download necessary dumps of
Wikipedia files. It check the checksums of files, so in case of problems it
reports it back to the user.

You can also run the task by issuing a `rake` task:

```bash
wiki$ export WIKI_DATA=/path/to/data 
wiki$ export WIKI_DB=/path/to/db 
wiki$ export WIKI_LANG=ja
wiki$ rake download
```


### Ragel

You need to compile the `content_offset` computation script,
since it is written in C. To do that you need `ragel`

```
sudo apt-get install ragel
```

And the call:

```
rake compile
```

### Runing scripts with Rake

You can run the scripts in a sequence by calling `rake`

```
WIKI_DATA=/path/to/sql/dumps WIKI_CONFIG=/path/to/config rake
```

This will decompress the files, extract the data and remove the uncompressed
files to save the space. There is one important exception `pages-articles.xml`
(the largest file) will remain uncompressed, since it is needed for further
processing.

## Results

* `pages.csv`
  * `page_id` - internal id of the page
  * `title` - the title of the page
  * `type` - the type of the page (same as in (Hadoop-CSV summary)[Wikipedia-miner-summary-files])
  * `depth` (unused)
  * `size` - the size of the page
* `articleParents.csv`
  * `article_id` - the id of the categorized article
  * rest - the ids of the categories the article belongs to
* `categoryParents.csv`
  * `article_id` - the id of the category
  * rest - the ids of the parent categories
* `childArticles.csv`
  * `category_id` - the id of the category
  * rest - the ids of articles that belong to the category
* `childCategories.csv`
  * `category_id` - the id of the category
  * rest - the ids of child categories
* `translations.csv`
  * `page_id` - the id of the page (article/category, etc.)
  * rest - pair of:
      * `language_code` - the code of the language
      * `translation` - the title of the corresponding (translated) article
* `templates.csv`
  * `page_id` - the id of the page
  * rest - titles of the included templates
* `linkBySource.csv`
  * `source_id` - the Wikipedia id of the source page of the links
  * rest - the names of Wikipedia articles linked from the source page
* `linkByTarget.csv`
  * `target_name` - the name of the target article of the links
  * rest - the Wikipedia ids of the articles linking to the target page

## Data 

Files in `data` dir:

* `sample-insert.sql` - sample file used to create and test the parser

## Docker

The scripts might be run with Docker and `docker compose`.

The service starts an infinite loop, so to run some rake task you have to do:
```
docker compose up
# in separate window
docker exec sql-sql-1 bundle exec rake download
```

By changing docker-compose environment variables, you can control the location of the data and the language.