require 'spec_helper'

module Rails; end unless defined?(Rails)

describe Leipreachan do
  before do
    ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'mysql2', 'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
    Rails.stub(:root).and_return('/tmp/Rails')
    Rails.stub(:env).and_return('test')
    Dir.stub(:new).and_return(['.', '..', '.DStore', '20150404000000.sql.gz', '20150403000000.sql.gz'])
  end

  it 'Has a version number' do
    expect(Leipreachan::VERSION).not_to be nil
  end

  it 'Defaults (max, date, dir)' do
    instance = Leipreachan.get_backuper_for Rails.env

    expect(instance.max_days).to eq(30)
    expect(instance.directory).to eq("backups")
    expect(instance.backup_folder).to eq(Date.current.strftime("%Y%m%d"))
    expect(instance.target_date).to eq(nil)
  end

  it 'Check DAYS from ENV' do
    instance = Leipreachan.get_backuper_for({'DAYS' => 100})
    expect(instance.max_days).to eq(100)
  end

  it 'Check DATE from ENV' do
    instance = Leipreachan.get_backuper_for({'DATE' => "20150404"})
    expect(instance.backup_folder).to eq('20150404')
    expect(instance.target_date).to eq('20150404')
  end

  it 'Check DIR from ENV' do
    instance = Leipreachan.get_backuper_for({'DIR' => "blah"})
    expect(instance.directory).to eq("blah")
  end

  it 'Remove unwanted backups' do
    instance = Leipreachan.get_backuper_for({'DAYS' => 2})
    Dir.unstub(:new)
    10.times.each  do |item|
      FileUtils.mkdir_p(File.join(instance.send(:base_path), (Date.current - item.day).strftime("%Y%m%d")))
    end
    instance.send(:remove_unwanted_backups)
    expect(Dir.new(instance.send(:base_path)).entries.sort).to eq(['.', '..', Date.current.strftime("%Y%m%d"), (Date.current - 1.day).strftime("%Y%m%d")].sort)
    FileUtils.rm_rf(Rails.root)
  end

  context 'MySQL: Backup and restore database without password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'mysql2', 'username' => 'login', 'password' => '', 'database' => 'dbname'}})
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan.get_backuper_for Rails.env }

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "mysqldump -h localhost -ulogin -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "mysql --silent --skip-column-names -e \"SHOW TABLES\" -h localhost -ulogin dbname | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h localhost -ulogin dbname"
    end

    it 'Restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -h localhost -ulogin dbname"
    end
  end

  context "MySQL: Backup and restore with password" do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'mysql2', 'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan.get_backuper_for Rails.env }

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "mysqldump -h localhost -ulogin -ppassword -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "mysql --silent --skip-column-names -e \"SHOW TABLES\" -h localhost -ulogin -ppassword dbname | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h localhost -ulogin -ppassword dbname"
    end

    it 'Restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -h localhost -ulogin -ppassword dbname"
    end
  end

  context 'Postgres: Backup and restore with password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'postgresql', 'user' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan.get_backuper_for Rails.env }

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "PGPASSWORD='password' pg_dump -h localhost -U login dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "PGPASSWORD='password' psql -h localhost -U login dbname -t -c \"select 'drop table \\\"' || tablename || '\\\" cascade;' from pg_tables where schemaname = 'public'\"  | PGPASSWORD='password' psql -h localhost -U login dbname"
    end

     it 'Restore' do
       instance.stub(:system) { |arg| arg }
       instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
       expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | PGPASSWORD='password' psql -h localhost -U login dbname"
     end
  end

  context 'Postgres: Backup and restore without password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'postgresql', 'user' => 'login', 'password' => '', 'database' => 'dbname'}})
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan.get_backuper_for Rails.env }

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "pg_dump -h localhost -U login dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "psql -h localhost -U login dbname -t -c \"select 'drop table \\\"' || tablename || '\\\" cascade;' from pg_tables where schemaname = 'public'\"  | psql -h localhost -U login dbname"
    end

    it 'Restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | psql -h localhost -U login dbname"
    end
  end

  context 'Other checks' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'postgresql', 'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan.get_backuper_for Rails.env }

    it 'backup_base_on return correct array' do
      expect(instance.send(:backup_folder_items)).to eq(['20150404000000.sql.gz', '20150403000000.sql.gz'])
    end
  end
end
