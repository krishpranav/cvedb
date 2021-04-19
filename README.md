# cvedb
A ruby tool for getting cve details

[![forthebadge](https://forthebadge.com/images/badges/made-with-ruby.svg)](https://forthebadge.com)

## Installation

Simply install this package with Rubygems:

    $ gem install fidius

Then add it to your gemfile (Rails 3)

    gem 'fidius-cvedb'
    gem 'mysql2' # only required when you use mysql db like in the example below

or environment.rb (prior Rails 3)

    require 'rubygems'
    require 'active_record'
    require 'fidius-cvedb'

Please note: The CVE-DB Gem has only been tested with Linux systems and might
not work with Windows.

## Configuration

The setup depends on the context you want to use the gem. It can be used in the
context of the FIDIUS Command&Control Server, or in your own Rails app. It might
access an already existing database or migrate a new one.

0. Go to your Rails-app folder and run `fidius-cvedb --standalone` or
   `fidius-cvedb --fidius`, depending on the context you are using it. For Rails
   versions prior 3 this will create symlinks for the Rake tasks.
1. Set up a new CVE Database if you need to or configure an existing one, add
   the CVE Database to your database.yml accordingly. Note that it must be named
   "cve_db":

          cve_db:
            adapter: mysql2
            encoding: utf8
            database: my_cve_database
            pool: 5
            username: my_username
            password: my_password
            host: localhost

2. When you created a new database, run `rake nvd:migrate` to create the tables
   needed.
3. When you set up your own database initialize it (note that it needs to be
   migrated before). Go to your Rails-app folder and run
   `rake nvd:initialize`. This will download all available information from the
   NVD, parse and store it in your database. This takes about 3 hours, depending
   on your machine. To keep your database up-to-date run `rake nvd:update`
   regularly, e.g. as a daily cron job.
4. Now you should be able to use the NVD entries, to test this go to your
   console (`rails console` | `ruby script/console`) and get an entry:

        $ FIDIUS::CveDb::NvdEntry.first


## Synopsis

This package comes with an executable script. You may invoke it as

    $ fidius-cvedb <option>

where _option_ may be:

* `-f` | `--fidius` Initialize CVE-DB for Usage in FIDIUS C&C-Server
* `-s` | `--standalone` Initialize CVE-DB standalone version
* `-h` | `--help` Show help message
* `-v` | `--version` Shows the gem version
