module Leipreachan
  class Backuper < DBBackup
    def system_check_list
      %w(gzip zcat mysql mysqldump)
    end

    def user
      @user ||= db_config['username'].present? ? "-u#{db_config['username']}" : ""
    end

    def password
      @password ||= db_config['password'].present? ? "-p#{db_config['password']} " : ""
    end

    def host
      @host ||= db_config['host'].present? ? db_config['host'] : "localhost"
    end

    def dbbackup!
      system("mysqldump -h #{host} #{user} #{password}-i -c -q --single-transaction #{db_config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      system("zcat < #{file} | mysql -h #{host} #{user} #{password}#{db_config['database']}")
    end

    private

    def drop_tables!
      system("mysql --silent --skip-column-names -e \"SHOW TABLES\" -h #{host} #{user} #{password}#{db_config['database']} | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h #{host} #{user} #{password}#{db_config['database']}")
    end
  end
end
