# encoding: utf-8

namespace :leipreachan do
  desc 'List of all backups; Options: DATE=20150130'
  task list: [:environment] do
    require 'leipreachan'
    Leipreachan::DBBackup.new(ENV).list
  end
  desc 'Restore project database; Options: DIR=backups RAILS_ENV=production MAX=30'
  task restore: [:environment] do
    require 'leipreachan'
    Leipreachan::DBBackup.new(ENV).restore!
  end
  desc "Backup project database; Options: DIR=backups RAILS_ENV=production MAX=30"
  task backup: [:environment] do
    require 'leipreachan'
    Leipreachan::DBBackup.new(ENV).backup!
  end
end
