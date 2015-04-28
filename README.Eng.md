# Leipreachan

As easiest as it is possible to be way for a database backup creating

## Installation

Add the follwing line to your Gemfile:

    gem 'leipreachan'

Run:

    $ bundle

Or install manually:

    $ gem install leipreachan

## Usage

### Capistrano 3

To create the backup copies in Capistrano you need to add the following line to the 'Capfile':

    require 'leipreachan/capistrano3'

This way the following tasks are added to Capistrano:

    cap deploy:leipreachan:backup      # Backup database
    cap deploy:leipreachan:list        # List of backups
    cap deploy:leipreachan:restore     # Restore database

If a backup copy is needed in course of an application deploy, the following file needs to be added to 'deploy.rb' line:

    before "deploy:migrate", "deploy:leipreachan:backup"

The backup copy will be created before database migrations.

The backup copy is created in 'shared/backups' by default. If there is a necessity of a folder setup, there is a 'backups_folder' variable:

    set :backups_folder, '../../current'

Gem uses a folder with a release as a basis. This should be considered in course of backup copy folder installation. 

For a recovery of the created backup, the following line needs to be run:

    $ cap [environment] deploy:leipreachan:restore

**!!!CAUTION!!!** The latest backup copy is recovered.

### Integration in Whenever

Add the following lines to 'config/schedule.rb':

    every 1.day, :at => '4:30 am' do
      rake "leipreachan:backup"
    end

A folder where the backups are stored can be changed. They are kept in './backups' by default. In other words, backups folder is created in the root folder of an application.

    every 1.month, do
      rake "leipreachan:backup DIR=/tmp/database_backups"
    end

There is an option of setting up an amount of days for how long the backups should be kept (note, that the tweak doesn't come with the a number of backups of a daily folder; there are unlimited backups every day). By default, 30 is stored directories, divided by dates.

    every 5.days, do
      rake "leipreachan:backup DAYS=5"
    end

### Rake tasks usage.

There are several rake tasks for handling database backups:

    rake leipreachan:backup   # Backup project database; Options: DIR=backups RAILS_ENV=production DAYS=30
    rake leipreachan:list     # List of all backups; Options: DATE=20150130
    rake leipreachan:restore  # Restore project database; Options: DIR=backups RAILS_ENV=production

* leipreachan:backup – creates database backup. 
* leipreachan:list – shows a list of days and a list of the backups within the last day. 
* leipreachan:restore – restores a database from a backup copy.

The options that can be turned over from an environment:

* DIR – a folder where a backup can be saved.
* DATE – to show the backups at a specified date
* DAYS – how many days the backups are stored.
