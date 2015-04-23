require 'leipreachan/version'
require 'leipreachan/railtie' if defined?(Rails)

module Leipreachan
  class DBBackup
    def initialize env
      @max_files = env['MAX'].to_i
      @target_date = env['DATE']
      directory = env['DIR']
      date_stamp = Time.now.strftime("%Y%m%d")
      datetime_stamp = Time.now.strftime("%Y%m%d%H%M%S")
      @base_path = File.join(Rails.root, directory || "backups")
      @backup_base = File.join(@base_path, @target_date || date_stamp)

      file_name = "#{datetime_stamp}.sql"
      @backup_file = File.join(@backup_base, file_name)

      @db_config = ActiveRecord::Base.configurations[Rails.env]
    end

    def backup!
      FileUtils.mkdir_p(@backup_base)
      case config['adapter']
      when 'postgresql'
        backup_pg!
      when 'mysql'
        backup_mysql!
      else
        raise "Incorrect adapter name!"
      end
      puts "Created backup: #{@backup_file}.gz"

      remove_unwanted_backups
    end

    def restore!
      case config['adapter']
      when 'postgresql'
        restore_pg!
      when 'mysql'
        restore_mysql!
      else
        raise "Incorrect adapter name!"
      end
    end

    def list
      if @target_date.present?
        single_date @target_date
      else
        all_dates
      end
    end

    def all_dates
      list = Dir.new(@base_path).entries.select{|name| name.match(/\d+/)}.sort
      list.first(list.size - 1).each_with_index do |folder, index|
        count = Dir.new(File.join(@base_path, folder)).entries.select{|name| name.match(/sql.gz$/)}.size
        puts "-> #{folder}: #{count}"
      end
      single_date list.last
    end

    def single_date date
      count = Dir.new(File.join(@base_path, date)).entries.select{|name| name.match(/sql.gz$/)}.size
      puts "-> #{date}: #{count}"
      Dir.new(File.join(@base_path, date)).entries.select{|name| name.match(/sql.gz$/)}.each_with_index do |backup, index|
        puts "   #{backup}"
      end
    end

    private

    def config
      @db_config
    end

    def remove_unwanted_backups
      all_backups = backup_folder_items

      max_backups = (@max_files if @max_files > 0) || 30
      unwanted_backups = all_backups[max_backups..-1] || []

      for unwanted_backup in unwanted_backups
        FileUtils.rm_rf(File.join(@backup_base, unwanted_backup))
      end
      puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available"
    end

    def backup_pg!
      username = config['username'].present? ? "-U #{config['username']}" : ""
      password = config['password'].present? ? "PGPASSWORD='#{config['password']}'" : ""
      `#{password} pg_dump #{username} #{config['database']} | gzip > #{@backup_file}.gz`
      raise "Unable to make DB backup!" if ( $?.to_i > 0 )
    end

    def backup_mysql!
      `mysqldump -u#{config['username']} -p#{config['password']} -i -c -q --single-transaction #{config['database']} | gzip > #{@backup_file}.gz`
      raise "Unable to make DB backup!" if ( $?.to_i > 0 )
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

    def restore_pg!
      file = get_file_for_restore
      username = config['username'].present? ? "-U #{config['username']}" : ""
      password = config['password'].present? ? "PGPASSWORD='#{config['password']}'" : ""
      drop_table_query = "drop schema public cascade; create schema public;"

      `echo "#{drop_table_query}" | #{password} psql #{username} #{config['database']}`
      `zcat < #{@backup_base}/#{file} | #{password} psql #{username} #{config['database']}`
    end

    def restore_mysql!
      file = get_file_for_restore
      `zcat < #{@backup_base}/#{file} | mysql -u#{config['username']} -p#{config['password']} #{config['database']}`
    end

    def backup_folder_items
      Dir.new(@backup_base).entries.select{|name| name.match(/sql.gz$/)}.sort.reverse
    end
  end
end
