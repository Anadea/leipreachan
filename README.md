# Leipreachan

Database backup as simple as should be.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'leipreachan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install leipreachan

## Usage

### Capistrano 3

For add backup tasks to Capistrano add to your 'Capfile' this line:

    require 'leipreachan/capistrano3'

It add new tasks:

    cap deploy:leipreachan:backup      # Backup database
    cap deploy:leipreachan:list        # List of backups
    cap deploy:leipreachan:restore     # Restore database

If you want to backup database during deploy you should add this line to 'deploy.rb':

    before "deploy:migrate", "deploy:leipreachan:backup"

It creates backup of database before run migrations.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/leipreachan/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
