module Leipreachan
  class Backuper < DBBackup
    def dbbackup!
      username = config['username'].present? ? "-U #{config['username']}" : ""
      password = config['password'].present? ? "PGPASSWORD='#{config['password']}' " : ""
      system("#{password}pg_dump #{username} #{config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      username = config['username'].present? ? "-U #{config['username']}" : ""
      password = config['password'].present? ? "PGPASSWORD='#{config['password']}' " : ""

      puts "Will be restored -> #{file}"
      puts ""
      drop_pg!
      system("zcat < #{backup_base_on(@target_date)}/#{file} | #{password}psql #{username} #{config['database']}")
    end

    private

    def drop_pg!
      username = config['username'].present? ? "-U #{config['username']}" : ""
      password = config['password'].present? ? "PGPASSWORD='#{config['password']}' " : ""
      drop_table_query = "drop schema public cascade; create schema public;"

      system("echo \"#{drop_table_query}\" | #{password}psql #{username} #{config['database']}")
    end
  end
end
