# yaml2sql

Writing boiler plate SQL for webscrapers (or just simple apps) is a pain. Make your life less stressful by specifying your sql as YAML and having this ruby lib create tables and basic insert statements as functions for you.

## Installation

```ruby
gem 'yaml2sql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaml2sql

## Usage

Specify your sql

```yaml
 name: poetry_project
 tables:
   - name: authors

     columns:
       - name: name
         type: text
       - name: url
         type: text
         unique: true

     indexes:
       - name: author_url_index
         table: authors
         key: url
       - name: author_name_index
         table: authors
         key: name

     select_from:
       url
```

Initialize a `Query` object

```ruby
create_table_statements = Query(PATH_TO_YAML)

db.exec create_table_statements


ins_statement = q.insert_authors('Plato', 'www.books.com/plato')

db.exec ins_statement


select_statement = q.select_authors('Plato')
db.exec select_statement

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nmaswood/yaml2sql.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
