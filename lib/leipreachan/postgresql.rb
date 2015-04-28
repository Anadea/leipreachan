module Leipreachan
  class Backuper < DBBackup
    def user
      @user ||= db_config['user'].present? ? "-U #{db_config['user']}" : ""
    end

    def password
      @password ||= db_config['password'].present? ? "PGPASSWORD='#{db_config['password']}' " : ""
    end

    def host
      @host ||= db_config['host'].present? ? db_config['host'] : "localhost"
    end

    def dbbackup!
      system("#{password}pg_dump -h #{host} #{db_config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      puts "Will be restored -> #{file}"
      puts ""
      drop_pg!
      system("zcat < #{backup_base_on(backup_folder)}/#{file} | #{password}psql -h #{host} #{user} #{db_config['database']}")
    end

    private

    def drop_pg!
      drop_table_query = "drop schema public cascade; create schema public;"
      system("echo \"#{drop_table_query}\" | #{password}psql -h #{host} #{user} #{db_config['database']}")
    end
  end
end
