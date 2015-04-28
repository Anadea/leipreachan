require 'leipreachan/version'
require 'leipreachan/railtie' if defined?(Rails)
require 'rails'
require 'active_record'

module Leipreachan
  def self.get_backuper_for env
    db_config = ActiveRecord::Base.configurations[Rails.env]
    require "leipreachan/#{db_config['adapter']}"
    Backuper.new(env)
  end

  class DBBackup
    MAX_DAYS = 30
    DIRECTORY = 'backups'

    attr_accessor :max_days,
                  :directory,
                  :target_date,
                  :backup_folder,
                  :backup_file,
                  :base_path,
                  :db_config,
                  :file_for_restore

    def initialize env
      @max_days = (env['DAYS'] || MAX_DAYS).to_i
      @target_date = env['DATE']
      @backup_folder = env['DATE'].presence || Time.now.strftime("%Y%m%d")
      @directory = env['DIR'] || DIRECTORY
      datetime_stamp = Time.now.strftime("%Y%m%d%H%M%S")
      @base_path = File.join(Rails.root, directory)
      @file_for_restore = env['FILE']

      file_name = "#{datetime_stamp}.sql"
      @backup_file = File.join(backup_base_on(backup_folder), file_name)

      @db_config = ActiveRecord::Base.configurations[Rails.env]
    end

    def backup!
      FileUtils.mkdir_p(backup_base_on(backup_folder))
      dbbackup!
      puts "Created backup: #{backup_file}.gz"
      backups_count = Dir.new(backup_base_on(backup_folder)).entries.select{|name| name.match(/sql.gz$/)}.size
      puts "#{backups_count} backups available for #{backup_folder} date"

      remove_unwanted_backups
    end

    def restore!
      dbrestore! get_file_for_restore
    end

    def restorefile!
      dbrestore! file_for_restore || get_lastfile_for_restore
    end

    def list
      target_date.present? ? single_date(target_date) : all_dates
    end

    private

    def get_backups_list folder
      Dir.new(backup_base_on(folder)).entries.select{|name| name.match(/sql.gz$/)}.sort
    end

    def all_dates
      list = Dir.new(base_path).entries.select{|name| name.match(/\d+/)}.sort
      list.first(list.size - 1).each_with_index do |folder, index|
        count = get_backups_list(folder).size
        puts "-> #{folder}: #{count}"
      end
      single_date list.last
    end

    def single_date date
      count = get_backups_list(date).size
      puts "-> #{date}: #{count}"
      get_backups_list(date).each_with_index do |backup, index|
        puts "   #{backup}"
      end
    end

    def backup_base_on target_date
      File.join(base_path, target_date)
    end

    def remove_unwanted_backups
      all_backups = Dir.new(base_path).entries.select{|folder| folder.match(/\d{8}/)}.sort.reverse

      max_backups = (max_days if max_days > 0) || MAX_DAYS
      unwanted_backups = all_backups[max_backups..-1] || []

      for unwanted_backup in unwanted_backups
        FileUtils.rm_rf(File.join(base_path, unwanted_backup))
      end
      puts "Deleted #{unwanted_backups.length} days, #{all_backups.length - unwanted_backups.length} days available"
    end

    def get_file_for_restore
      backups_list = backup_folder_items.reverse
      backups_list.each_with_index do |backup, index|
        puts "#{index}. #{backup}"
      end
      puts "="*80
      puts "WARNING!!! YOUR CURRENT DATABASE DATA WILL BE LOST!!!"
      puts "Think twice before push the Enter button"
      puts "="*80
      puts "Enter file name to restore: [#{backups_list.last}]"
      STDIN.gets.chomp.presence || backups_list.last
    end

    def get_lastfile_for_restore
      backup_folder_items.reverse.last
    end

    def backup_folder_items
      get_backups_list(backup_folder).reverse
    end
  end
end
