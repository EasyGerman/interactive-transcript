# README

## Installation

### Requirements

* Ruby - best to install it with [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/).
* Node.js
* PostgreSQL
* EasyGerman private podcast URL (from Patreon)
* DeepL API key (for translations)
* Rollbar (for error reporting)

### Application setup

```sh
gem install bundler
bundle install
cp .env.development.sample .env.development
cp config/database.yml.example config/database.yml
```

Customize .env.development and database.yml.

Set up the database:

```sh
rails db:setup
```

### Starting the server

```sh
./bin/run
```

## Running the tests

```sh
bundle exec rspec
```

or use guard to run tests as files change:

```sh
guard
```

Data tests are normally excluded because they require patron-only content.

To download contents, run the following:

```ruby
bundle exec rake feed:import_to_files
```

```ruby
PODCAST=easygerman EPISODES=all bundle exec rspec spec/modules/processing_spec.rb
```

## Deployment to Heroku

On Heroku Dashboard:

* create app
* add PostgreSQL and Redis add-ons
* set environment variables (refer to .env.development - ignore DATABASE_URL & REDIS_URL, these are set automatically by Heroku)

On the CLI:

```sh
git remote add heroku https://git.heroku.com/<appname>.git
git push heroku master
```

## Rake tasks

- `rake feed:stats` - print stats about all episodes
- `rake translations:prepopulate` - pre-translate all transcripts
