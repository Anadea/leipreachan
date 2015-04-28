# encoding: utf-8

namespace :leipreachan do
  desc 'List of all backups; Options: DATE=20150130'
  task list: [:environment] do
    require 'leipreachan'
    Leipreachan.get_backuper_for(ENV).list
  end
  desc 'Restore project database; Options: DIR=backups RAILS_ENV=production DAYS=30'
  task restore: [:environment] do
    require 'leipreachan'
    Leipreachan.get_backuper_for(ENV).restore!
  end
  task restorefile: [:environment] do
    require 'leipreachan'
    Leipreachan.get_backuper_for(ENV).restorefile!
  end
  desc "Backup project database; Options: DIR=backups RAILS_ENV=production DAYS=30"
  task backup: [:environment] do
    require 'leipreachan'
    Leipreachan.get_backuper_for(ENV).backup!
  end
end
