module Leipreachan
  class Backuper < DBBackup
    def dbbackup!
      password = config['password'].present? ? "-p#{config['password']} " : ""
      system("mysqldump -u#{config['username']} #{password}-i -c -q --single-transaction #{config['database']} | gzip > #{backup_file}.gz")
    end

    def dbrestore! file
      password = config['password'].present? ? "-p#{config['password']} " : ""
      system("zcat < #{backup_base_on(@target_date)}/#{file} | mysql -u#{config['username']} #{password}#{config['database']}")
    end
  end
end
