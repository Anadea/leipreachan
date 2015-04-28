module Leipreachan
  class Backuper < DBBackup
    def dbbackup!
      password = db_config['password'].present? ? "-p#{db_config['password']} " : ""
      system("mysqldump -u#{db_config['username']} #{password}-i -c -q --single-transaction #{db_config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      password = db_config['password'].present? ? "-p#{db_config['password']} " : ""
      system("zcat < #{backup_base_on(backup_folder)}/#{file} | mysql -u#{db_config['username']} #{password}#{db_config['database']}")
    end
  end
end
