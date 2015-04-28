module Leipreachan
  class Backuper < DBBackup
    def dbbackup!
      username = db_config['username'].present? ? "-U #{db_config['username']}" : ""
      password = db_config['password'].present? ? "PGPASSWORD='#{db_config['password']}' " : ""
      system("#{password}pg_dump #{username} #{db_config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      username = db_config['username'].present? ? "-U #{db_config['username']}" : ""
      password = db_config['password'].present? ? "PGPASSWORD='#{db_config['password']}' " : ""

      puts "Will be restored -> #{file}"
      puts ""
      drop_pg!
      system("zcat < #{backup_base_on(backup_folder)}/#{file} | #{password}psql #{username} #{db_config['database']}")
    end

    private

    def drop_pg!
      username = db_config['username'].present? ? "-U #{db_config['username']}" : ""
      password = db_config['password'].present? ? "PGPASSWORD='#{db_config['password']}' " : ""
      drop_table_query = "drop schema public cascade; create schema public;"

      system("echo \"#{drop_table_query}\" | #{password}psql #{username} #{db_config['database']}")
    end
  end
end
